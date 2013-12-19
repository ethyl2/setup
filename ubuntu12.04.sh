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

if ! [ -e /etc/apt/sources.list.d/marutter-rrutter-precise.list ]; then
	add-apt-repository -y ppa:marutter/rrutter
	apt-get -y update
fi

if ! [ -e /etc/apt/sources.list.d/webupd8team-java-precise.list ]; then
	add-apt-repository -y ppa:webupd8team/java
	apt-get -y update
fi

if ! [ -e /etc/apt/sources.list.d/aims-sagemath-precise.list ]; then
	add-apt-repository -y ppa:aims/sagemath
	apt-get -y update
fi

apt-get -y dist-upgrade

apt-get -y install \
	alarm-clock-applet \
	antiword \
	apt-file \
	bison \
	build-essential \
	bzr \
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
	git-svn \
	gitk \
	gnustep-devel \
	gobjc \
	gobjc++ \
	gradle-ppa \
	groovy \
	htop \
	iotop \
	inkscape \
	libarmadillo-dev \
	libboost1.48-all-dev \
	libboost1.48-doc \
	libcommons-cli-java \
	libcurl4-openssl-dev \
	libgdbm-dev \
	libimage-exiftool-perl \
	liblapack-dev \
	libprotobuf-dev \
	libsqlite3-dev \
	libtool \
	libwpd-tools \
	libxml2-dev \
	libxslt1-dev \
	libyaml-dev \
	lua5.2 \
	lua5.2-doc \
	lyx \
	meld \
	mercurial \
	molly-guard \
	monodevelop \
	mono-gmcs \
	mono-mcs \
	nautilus-dropbox \
	nethogs \
	network-manager-vpnc \
	nmap \
	nodejs \
	nunit-console \
	octave3.2 \
	openjdk-6-jdk \
	openjdk-7-jdk \
	oracle-java7-installer \
	php5 \
	pstotext \
	python \
	python-chardet \
	python-chm \
	python-easygui \
	python-mutagen \
	python-virtualenv \
	r-base \
	r-base-dev \
	r-cran-boot \
	r-cran-class \
	r-cran-cluster \
	r-cran-codetools \
	r-cran-foreign \
	r-cran-kernsmooth \
	r-cran-lattice \
	r-cran-mass \
	r-cran-matrix \
	r-cran-mgcv \
	r-cran-nlme \
	r-cran-nnet \
	r-cran-rpart \
	r-cran-spatial \
	r-cran-survival \
	r-cran-rodbc \
	recoll \
	recoll-lens \
	sagemath-upstream-binary \
	scala \
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
	valgrind \
	vim \
	vim-doc \
	vim-gnome \
	vpnc \
	wv \
	xchat

#if lspci | grep -q VMware; then
#	apt-get -y install \
#		open-vm-tools \
#		open-vm-toolbox \
#		open-vm-dkms
#fi

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

if ! dpkg -l sbt; then
	latest_sbt_url=$(wget -q -O- http://www.scala-sbt.org/release/docs/Getting-Started/Setup.html | grep -o -P 'https?://repo\.scala-sbt\.org/[^"]*sbt\.deb' | tail -1)
	wget -O /tmp/sbt.deb "$latest_sbt_url"
	dpkg -i /tmp/sbt.deb || true
	apt-get -fy install
fi

if ! [ -e /usr/local/scala/eclipse ]; then
	latest_scala_eclipse_url=$(wget -q -O- http://scala-ide.org/download/sdk.html | grep -o -P 'https?://.*typesafe\.com/.*/scala-SDK-.*-linux.gtk.x86_64.tar.gz' | tail -1)
	wget -O /tmp/scala-sdk.tar.gz "$latest_scala_eclipse_url"
	mkdir -p /usr/local/scala
	tar xzvf /tmp/scala-sdk.tar.gz -C /usr/local/scala
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

if ! [ -e /usr/lib/vmware-cip/5.5.0 ]; then
	if [ -e /net/hurley/storage/data/pub/software/VMware/VMware-ClientIntegrationPlugin-5.5.0.x86_64.bundle ]; then
		yes yes | sh -c 'PAGER=/bin/cat sh /net/hurley/storage/data/pub/software/VMware/VMware-ClientIntegrationPlugin-5.5.0.x86_64.bundle --console --required'
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

# May want to make this conditional on something, but I'm not sure what. Maybe just leave it out?
#update-java-alternatives --set java-7-oracle
