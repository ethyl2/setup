sudo apt-get install git
git config --global user.email "danielnuffer@gmail.com"
git config --global user.name "Dan Nuffer"
git config --global push.default matching

sudo chmod +x /usr/share/doc/git/contrib/subtree/git-subtree.sh
sudo ln -s /usr/share/doc/git/contrib/subtree/git-subtree.sh /usr/lib/git-core/git-subtree

sudo add-apt-repository ppa:chris-lea/node.js
sudo apt-get update

sudo apt-get install \
	build-essential \
	ccache \
	clisp \
	clojure1.4 \
	coffeescript \
	default-jdk \
	dvipng \
	erlang \
	gnustep-devel \
	gobjc \
	gobjc++ \
	groovy \
	libboost1.53-all-dev \
	libboost1.53-doc \
	lua5.2 \
	lua5.2-doc \
	mono-mcs \
	nodejs \
	octave \
	php5 \
	python \
	r-base \
	ruby \
	ruby-dev \
	scala \
	texlive-latex-base \
	vim-doc \
	vim-gnome

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

cat > /etc/cron.weekly/fstrim << EOS
#! /bin/sh
for mount in /; do
	fstrim $mount
done
EOS

# TODO: Add ,discard to /etc/crypttab
# TODO: change issue_discards = 0 to 1 in /etc/lvm/lvm.conf

# TODO: autofs
