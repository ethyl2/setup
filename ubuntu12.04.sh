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
apt-get -y install git curl

if ! [ -x /usr/lib/git-core/git-subtree ]; then
	curl --location https://raw.github.com/git/git/master/contrib/subtree/git-subtree.sh > /usr/lib/git-core/git-subtree
	chmod +x /usr/lib/git-core/git-subtree
fi

if ! [ -e /etc/apt/sources.list.d/chris-lea-node_js-precise.list ]; then
	add-apt-repository -y ppa:chris-lea/node.js
	apt-get -y update
fi

if ! [ -e /etc/apt/sources.list.d/ubuntu-toolchain-r-test-precise.list ]; then
	add-apt-repository -y ppa:ubuntu-toolchain-r/test
	apt-get -y update
fi

if ! [ -e /etc/apt/sources.list.d/cwchien-gradle-precise.list ]; then
	add-apt-repository -y ppa:cwchien/gradle
	apt-get -y update
fi

if ! [ -e /etc/apt/sources.list.d/recoll-backports-recoll-1_15-on-precise.list ]; then
	add-apt-repository -y ppa:recoll-backports/recoll-1.15-on
	apt-get -y update
fi

apt-get -y upgrade

apt-get -y install \
	alarm-clock-applet \
	antiword \
	bison \
	build-essential \
	catdoc \
	ccache \
	clang \
	clisp \
	clojure1.3 \
	cmake \
	coffeescript \
	default-jdk \
	djvulibre-bin \
	dvipng \
	erlang \
	freemind \
	g++-4.8 \
	gawk \
	gcc-4.8 \
	gimp \
	git-gui \
	gitk \
	gnustep-devel \
	gobjc \
	gobjc++ \
	gradle-ppa \
	groovy \
	htop \
	inkscape \
	libboost1.48-all-dev \
	libboost1.48-doc \
	libcommons-cli-java \
	libcurl4-openssl-dev \
	libgdbm-dev \
	libimage-exiftool-perl \
	libprotobuf-dev \
	libsqlite3-dev \
	libtool \
	libxml2-dev \
	libyaml-dev \
	lua5.2 \
	lua5.2-doc \
	meld \
	mercurial \
	molly-guard \
	monodevelop \
	mono-gmcs \
	mono-mcs \
	nautilus-dropbox \
	nethogs \
	network-manager-vpnc \
	nodejs \
	nunit-console \
	octave3.2 \
	php5 \
	pstotext \
	python \
	python-chm \
	python-mutagen \
	python-virtualenv \
	r-base \
	recoll \
	recoll-lens \
	scala \
	shutter \
	ssh \
	texlive-latex-base \
	tree \
	ttf-dejavu \
	unrtf \
	untex \
	vim \
	vim-doc \
	vim-gnome \
	vpnc \
	xchat

if lspci | grep -q VMware; then
	apt-get -y install \
		open-vm-tools \
		open-vm-toolbox \
		open-vm-dkms
fi

install_R_package() {
	package=$1
	if ! [ -e "/usr/local/lib/R/site-library/$package" ]; then
		R -e "install.packages(\"$package\", repos=\"http://R-Forge.R-project.org\")"
	fi
}

# TODO: figure out how to not install this globally and only for the project that uses it.
install_R_package svUnit

if ! [ -e /usr/share/X11/xorg.conf.d/60-synaptics-options.conf ]; then
cat > /usr/share/X11/xorg.conf.d/60-synaptics-options.conf << EOS
Section "InputClass"
  Identifier "touchpad catchall"
  Driver "synaptics"
  MatchIsTouchpad "on"
  MatchDevicePath "/dev/input/event*"

  Option "FingerLow" "40"
  Option "FingerHigh" "45"

EndSection
EOS
fi

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
	curl --location -o /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	dpkg -i /tmp/google-chrome-stable_current_amd64.deb || true
	apt-get -fy install
fi

if ! dpkg -l anki | grep '^ii.*anki'; then
	curl --location -o /tmp/anki-2.0.15.deb http://ankisrs.net/download/mirror/anki-2.0.15.deb
	dpkg -i /tmp/anki-2.0.15.deb || true
	apt-get -fy install
fi

# Install python epub module for recoll indexing of epub files
if ! [ -e /usr/local/lib/python2.7/dist-packages/epub ]; then
	pip install epub
fi

if ! [ -e /usr/bin/vmware ]; then
	if [ -e /net/hurley/storage/data/pub/software/VMware/VMware-Workstation-Full-9.0.2-1031769.x86_64.txt ]; then
		yes yes | sh -c 'PAGER=/bin/cat sh /net/hurley/storage/data/pub/software/VMware/VMware-Workstation-Full-9.0.2-1031769.x86_64.txt --console --required'
		/usr/lib/vmware/bin/vmware-vmx --new-sn `cat /net/hurley/storage/data/pub/software/VMware/serials/Workstation9.txt`
	else
		echo "VMware Workstation not installed because the install isn't at the expected path" >&2
	fi
fi

if ! [ -e /usr/lib/vmware-cip/5.1 ]; then
	if [ -e /net/hurley/storage/data/pub/software/VMware/VMware-ClientIntegrationPlugin-5.1.0.x86_64.bundle ]; then
		yes yes | sh -c 'PAGER=/bin/cat sh /net/hurley/storage/data/pub/software/VMware/VMware-ClientIntegrationPlugin-5.1.0.x86_64.bundle --console --required'
	fi
fi

if ! [ -e /usr/local/crashplan/bin ]; then
	if ! [ -e /tmp/CrashPlan-install ]; then
		curl --location http://download.crashplan.com/installs/linux/install/CrashPlan/CrashPlan_3.5.3_Linux.tgz | tar -C /tmp -xzvf -
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

if ! [ -e /usr/local/heroku/bin/heroku ]; then
	wget -qO- https://toolbelt.heroku.com/install-ubuntu.sh | sh
fi

# See http://www.reddit.com/r/linux/comments/17sov5/howto_beats_audio_hp_laptop_speakers_on/
if lspci | grep 'Audio device: Intel Corporation 7 Series/C210 Series Chipset Family High Definition Audio Controller (rev 04)'; then
	if ! [ -e /lib/firmware/hda-jack-retask.fw ]; then
		cat > /lib/firmware/hda-jack-retask.fw << EOS
[codec]
0x111d76e0 0x103c181b 0

[pincfg]
0x0a 0x04a11020
0x0b 0x0421101f
0x0c 0x40f000f0
0x0d 0x90170150
0x0e 0x40f000f0
0x0f 0x90170150
0x10 0x90170151
0x11 0xd5a30130
0x1f 0x40f000f0
0x20 0x40f000f0
EOS
	fi

	if ! [ -e /etc/modprobe.d/hda-jack-retask.conf ]; then
  		cat > /etc/modprobe.d/hda-jack-retask.conf << EOS
# This file was added by the program 'hda-jack-retask'.
# If you want to revert the changes made by this program, you can simply erase this file and reboot your computer.
options snd-hda-intel patch=hda-jack-retask.fw,hda-jack-retask.fw,hda-jack-retask.fw,hda-jack-retask.fw
EOS
	fi
fi
