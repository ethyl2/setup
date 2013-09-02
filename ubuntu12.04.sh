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
	curl https://raw.github.com/git/git/master/contrib/subtree/git-subtree.sh > /usr/lib/git-core/git-subtree
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

apt-get -y upgrade

apt-get -y install \
	alarm-clock-applet \
	build-essential \
	ccache \
	clang \
	clisp \
	clojure1.3 \
	coffeescript \
	default-jdk \
	dvipng \
	erlang \
	freemind \
	g++-4.8 \
	gcc-4.8 \
	gimp \
	git-gui \
	gitk \
	gnustep-devel \
	gobjc \
	gobjc++ \
	golang \
	groovy \
	htop \
	inkscape \
	libboost1.48-all-dev \
	libboost1.48-doc \
	libcommons-cli-java \
	libcurl4-openssl-dev \
	libprotobuf-dev \
	libtool \
	libxml2-dev \
	lua5.2 \
	lua5.2-doc \
	meld \
	molly-guard \
	mono-mcs \
	monodevelop \
	nautilus-dropbox \
	nethogs \
	network-manager-vpnc \
	nodejs \
	octave3.2 \
	php5 \
	python \
	python-virtualenv \
	r-base \
	ruby1.9.1-full \
	scala \
	shutter \
	ssh \
	texlive-latex-base \
	tree \
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
fi

REALLY_GEM_UPDATE_SYSTEM=yes gem update --system

if ! [ -x /usr/bin/rspec ]; then
	gem install --no-rdoc rspec
fi

if ! [ -x /usr/bin/rake ]; then
	gem install --no-rdoc rake
fi

if ! [ -x /usr/bin/pry ]; then
	gem install --no-rdoc --no-ri pry
fi

if ! [ -x /usr/bin/rake-compiler ]; then
	gem install --no-rdoc rake-compiler
fi

export NODE_PATH=/usr/lib/nodejs:/usr/lib/node_modules:/usr/share/javascript

install_node_module() {
	module=$1
	if ! nodejs -e 'require("'$module'")'; then
		npm install -g $module
	fi
}
install_node_module "optimist"
install_node_module "karma"
install_node_module "mocha"
install_node_module "should"

install_go_package() {
	package=$1
	if ! [ -e "/usr/lib/go/src/pkg/$package" ]; then
		go get "$package"
	fi
}

install_go_package "github.com/jessevdk/go-flags"

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
		curl http://download.crashplan.com/installs/linux/install/CrashPlan/CrashPlan_3.5.3_Linux.tgz | tar -C /tmp -xzvf -
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

