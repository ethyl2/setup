#!/bin/bash
set -x
set -e
set -u

if [ $UID != "0" ]; then
	echo "This script must be run as root" >&2
	exit 1
fi

sed -i -e 's/us.archive.ubuntu.com/mirrors.xmission.com/g' /etc/apt/sources.list
sed -i -e 's/security.ubuntu.com/mirrors.xmission.com/g' /etc/apt/sources.list

apt-get update
apt-get -y install git curl wget

if ! [ -x /usr/lib/git-core/git-subtree ]; then
	wget -O /usr/lib/git-core/git-subtree https://raw.github.com/git/git/master/contrib/subtree/git-subtree.sh
	chmod +x /usr/lib/git-core/git-subtree
fi

if ! [ -e /etc/apt/sources.list.d/recoll-backports-recoll-1_15-on-precise.list ]; then
	add-apt-repository -y ppa:recoll-backports/recoll-1.15-on
	apt-get -y update
fi

apt-get -y dist-upgrade

apt-get -y install \
	p7zip-full \
	p7zip-rar \
	alarm-clock-applet \
	antiword \
	apt-file \
	bison \
	build-essential \
	bzr \
	catdoc \
	ccache \
	clang \
	cmake \
	default-jdk \
	djvulibre-bin \
	dvipng \
	gawk \
	gimp \
	git-gui \
	gitk \
	git-svn \
	inkscape \
	ipython \
	ipython-notebook \
	libcurl4-openssl-dev \
	libimage-exiftool-perl \
	libwpd-tools \
	lyx \
	meld \
	mercurial \
	molly-guard \
	nautilus-dropbox \
	nethogs \
	pstotext \
	python \
	python-chardet \
	python-chm \
	python-easygui \
	python-mutagen \
	python-nose \
	python-tk \
	python-virtualenv \
	recoll \
	recoll-lens \
	screen \
	shutter \
	ssh \
	subversion \
	texlive-latex-base \
	tree \
	ttf-dejavu \
	ubuntu-restricted-extras \
	unattended-upgrades \
	unrar \
	unrtf \
	untex \
	vim \
	vim-doc \
	vim-gnome \
	vpnc \
	wv \
	xchat

if ! [ -e /etc/cron.weekly/fstrim ]; then
cat > /etc/cron.weekly/fstrim << EOS
#!/bin/sh
for mount in /; do
	fstrim \$mount
done
EOS
chmod 755 /etc/cron.weekly/fstrim
fi

apt-get -y install autofs
sed -i -e 's/^#\/net	-hosts$/\/net	-hosts/' /etc/auto.master
restart autofs

if ! dpkg -l google-chrome-stable | grep '^ii.*google-chrome-stable'; then
	wget -O /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	dpkg -i /tmp/google-chrome-stable_current_amd64.deb || true
	apt-get -fy install
fi

if ! dpkg -l anki | grep '^ii.*anki'; then
	latest_anki_url=$(wget -q -O- http://ankisrs.net/ | grep -o -P 'https?://.*anki[^/]*deb' | tail -1)
	wget -O /tmp/anki.deb "$latest_anki_url"
	dpkg -i /tmp/anki.deb || true
	apt-get -fy install
fi

if ! dpkg -l google-talkplugin; then
	wget -O /tmp/google-talkplugin_current_amd64.deb https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
	dpkg -i /tmp/google-talkplugin_current_amd64.deb || true
	apt-get -fy install
fi

# Install python epub module for recoll indexing of epub files
if ! [ -e /usr/local/lib/python2.7/dist-packages/epub ]; then
	pip install epub
fi

# Install python rarfile module for recoll indexing of rar files
if ! [ -e /usr/local/lib/python2.7/dist-packages/rarfile.py ]; then
	pip install rarfile
fi

if ! [ -e /usr/bin/vmware ]; then
	if [ -e /net/hurley/storage/data/pub/software/VMware/VMware-Workstation-Full-9.0.2-1031769.x86_64.txt ]; then
		yes yes | sh -c 'PAGER=/bin/cat sh /net/hurley/storage/data/pub/software/VMware/VMware-Workstation-Full-9.0.2-1031769.x86_64.txt --console --required'
		/usr/lib/vmware/bin/vmware-vmx --new-sn `cat /net/hurley/storage/data/pub/software/VMware/serials/Workstation9.txt`
	else
		echo "VMware Workstation not installed because the install isn't at the expected path" >&2
	fi
fi

if ! [ -e /usr/local/crashplan/bin ]; then
	if ! [ -e /tmp/CrashPlan-install ]; then
		wget -O- http://download.crashplan.com/installs/linux/install/CrashPlan/CrashPlan_3.5.3_Linux.tgz | tar -C /tmp -xzvf -
	fi
	pushd /tmp/CrashPlan-install
	echo "fs.inotify.max_user_watches=10485760" >> /etc/sysctl.conf
	sysctl -p
	echo '#!/bin/sh' > more
	chmod +x more
	#PATH=.:/usr/bin:/bin:/usr/sbin:/sbin ./install.sh
	bash -c 'PATH=.:/usr/bin:/bin:/usr/sbin:/sbin ./install.sh' << EOS



yes
EOS
	popd
	rm -rf /tmp/CrashPlan-install
fi
