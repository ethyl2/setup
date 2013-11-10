#!/bin/bash
set -x
set -e
set -u 

sudo apt-get install git
git config --global user.name "Dan Nuffer"
git config --global push.default matching


if ! [ -e ~/.ssh/id_rsa.pub ]; then
	ssh-keygen
	echo "Add this key to github"
	cat ~/.ssh/id_rsa.pub
	echo "Press enter when finished"
	read ans
fi

if ! [ -d ~/myvim ]; then
	pushd ~
	git clone ssh://git@github.com/dnuffer/myvim
	pushd ~/myvim
	./install.sh
	popd
	popd
fi

if ! [ -d ~/dpcode ]; then
	pushd ~
	git clone ssh://git@github.com/dnuffer/dpcode
	popd
fi

if ! [ -e /etc/sudoers.d/$USER ]; then
	OLD_MODE=`umask`
	umask 0227
	echo "Defaults always_set_home" | sudo tee -a /etc/sudoers.d/$USER
	echo "$USER ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/$USER
	umask $OLD_MODE
fi

# setup gnome-terminal unlimited scrollback and white on black color theme
gconftool --set /apps/gnome-terminal/profiles/Default/alternate_screen_scroll true --type bool
gconftool --set /apps/gnome-terminal/profiles/Default/scrollback_lines 512000 --type int
gconftool --set /apps/gnome-terminal/profiles/Default/use_theme_colors false --type bool
gconftool --set /apps/gnome-terminal/profiles/Default/palette '#2E2E34343636:#CCCC00000000:#4E4E9A9A0606:#C4C4A0A00000:#34346565A4A4:#757550507B7B:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC' --type string
gconftool --set /apps/gnome-terminal/profiles/Default/background_color '#000000000000' --type string
gconftool --set /apps/gnome-terminal/profiles/Default/bold_color '#000000000000' --type string
gconftool --set /apps/gnome-terminal/profiles/Default/foreground_color '#FFFFFFFFFFFF' --type string

if ! grep ccache ~/.bashrc >/dev/null; then
	echo "export PATH=/usr/lib/ccache:\$PATH" >> ~/.bashrc
fi

if ! grep StrictHostKeyChecking ~/.ssh/config; then
	echo 'Host *' >> ~/.ssh/config
	echo "  StrictHostKeyChecking no" >> ~/.ssh/config
fi

if ! [ -e ~/.gvm ]; then
	bash < <(curl -s https://raw.github.com/moovweb/gvm/master/binscripts/gvm-installer)
	source $HOME/.gvm/scripts/gvm
	gvm install go1
	gvm install go1.1.2
	gvm use go1
fi

if ! [ -e ~/.rvm ]; then
	curl -L https://get.rvm.io | bash -s stable --ruby=2.0
	source $HOME/.rvm/scripts/rvm
fi

if ! [ -e ~/.Renviron ]; then
	echo 'R_LIBS_USER="~/.Rlibs"' > ~/.Renviron
fi

if ! [ -e ~/.Rlibs ]; then
	mkdir ~/.Rlibs
fi

install_R_package() {
	package=$1
	if ! [ -e "$HOME/.Rlibs/*/$package" ]; then
		R -e "install.packages(\"$package\", dependencies = TRUE, repos=\"http://cran.cnr.Berkeley.edu\", lib=\"~/.Rlibs\")"
	fi
}

# TODO: figure out how to not install this globally and only for the project that uses it.
install_R_package knitr
install_R_package Hmisc
install_R_package maps
install_R_package devtools
install_R_package roxygen2
install_R_package testthat

