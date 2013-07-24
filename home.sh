#!/bin/bash
set -x
set -e
set -u 

sudo apt-get install git
git config --global user.email "danielnuffer@gmail.com"
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

if ! [ -e /etc/sudoers.d/dan ]; then
	OLD_MODE=`umask`
	umask 0227
cat | sudo tee /etc/sudoers.d/dan << EOS
$USER ALL=(ALL) NOPASSWD: ALL
EOS
	umask $OLD_MODE
fi


