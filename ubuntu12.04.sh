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
apt-get -y upgrade
apt-get -y install git curl

if ! [ -x /usr/lib/git-core/git-subtree ]; then
	curl https://raw.github.com/git/git/master/contrib/subtree/git-subtree.sh > /usr/lib/git-core/git-subtree
	chmod +x /usr/lib/git-core/git-subtree
fi

if ! [ -e /etc/apt/sources.list.d/chris-lea-node_js-precise.list ]; then
	add-apt-repository -y ppa:chris-lea/node.js
	apt-get -y update
fi

apt-get -y install \
	build-essential \
	ccache \
	clisp \
	clojure1.3 \
	coffeescript \
	default-jdk \
	dvipng \
	erlang \
	freemind \
	gimp \
	git-gui \
	gitk \
	gnustep-devel \
	gobjc \
	gobjc++ \
	golang \
	groovy \
	inkscape \
	libboost1.48-all-dev \
	libboost1.48-doc \
	lua5.2 \
	lua5.2-doc \
	meld \
	mono-mcs \
	nautilus-dropbox \
	nodejs \
	octave3.2 \
	php5 \
	python \
	r-base \
	ruby1.9.1-full \
	scala \
	shutter \
	texlive-latex-base \
	ttf-dejavu \
	vim \
	vim-doc \
	vim-gnome \
	vpnc

if ! [ -x /usr/bin/gem ]; then
	wget http://production.cf.rubygems.org/rubygems/rubygems-2.0.6.tgz
	tar xzvf rubygems-2.0.6.tgz
	pushd rubygems-2.0.6
	ruby setup.rb
	popd
	rm -rf rubygems-2.0.6*
	gem update --system
fi

if ! [ -x /usr/local/bin/rspec ]; then
	gem install rspec
fi

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
#! /bin/sh
for mount in /; do
	fstrim \$mount
done
EOS
fi

apt-get -y install autofs
sed -i -e 's/^#\/net	-hosts$/\/net	-hosts/' /etc/auto.master
restart autofs

if ! dpkg -l google-chrome-stable | grep '^ii.*google-chrome-stable'; then
	curl -o /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	dpkg -i /tmp/google-chrome-stable_current_amd64.deb || true
	apt-get -fy install
fi

if ! dpkg -l anki | grep '^ii.*anki'; then
	curl -o /tmp/anki-2.0.12.deb https://anki.googlecode.com/files/anki-2.0.12.deb
	dpkg -i /tmp/anki-2.0.12.deb || true
	apt-get -fy install
fi

if ! [ -e /usr/bin/vmware ]; then
	if [ -e /net/hurley/storage/data/pub/software/VMware/VMware-Workstation-Full-9.0.2-1031769.x86_64.txt ]; then
		yes yes | sudo sh -c 'PAGER=/bin/cat sh /net/hurley/storage/data/pub/software/VMware/VMware-Workstation-Full-9.0.2-1031769.x86_64.txt --console --required'
		/usr/lib/vmware/bin/vmware-vmx --new-sn `cat /net/hurley/storage/data/pub/software/VMware/serials/Workstation9.txt`
	else
		echo "VMware Workstation not installed because the install isn't at the expected path" >&2
	fi
fi
