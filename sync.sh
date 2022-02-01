#!/bin/bash

INSTALL_STR="${INSTALL_STRING_NO_INPUT:-sudo apt install -y}"
PACKAGES="${INSTALL_PACKAGES_STRING:-zsh awesome}"
CWD=$(pwd)
VERBOSE=0

function __verbose {
	if [ $VERBOSE -eq 1 ]; then
		$@
	else
		$@ &> /dev/null
	fi
}

function install {
	echo "> install"
	echo "# installing packages"
	__verbose $INSTALL_STR $PACKAGES
	echo "# installing ohmyzsh"
	__verbose sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 	
	echo "# installing pfetch"
	__verbose git clone https://github.com/dylanaraps/pfetch.git /tmp/dotfiles-pfetch 		
	cd /tmp/dotfiles-pfetch; sudo make install
	cd $CWD
}

function setDefaults {
	echo "> setDefaults"
	sudo chsh -s /bin/zsh $(whoami)
}

function cleanHome {
	echo "> cleanHome"
	__verbose rm -rf ~/.config/awesome 	
	__verbose rm -rf ~/.zshrc			
}

function clean {
	echo "> clean"
	__verbose rm -rf /tmp/awesome-copycats 	
}

function awesomeUpdate {
	echo "> awesomeUpdate"
	__verbose git clone \
		--recurse-submodules --remote-submodules --depth 1 -j 2 \
		https://github.com/lcpz/awesome-copycats.git /tmp/awesome-copycats 
	mkdir -p ~/.config/awesome
	mv /tmp/awesome-copycats ~/.config/awesome
	cp ./configfiles/awesome-rc.lua ~/.config/awesome/rc.lua
	__verbose rm -rf /tmp/awesome-copycats
}

function symlinks {
	echo "> links"
	ln configfiles/zshrc ~/.zshrc
}

git fetch

clean 
if [[ "$@" == *"-v"* ]]; then
	VERBOSE=1
fi
if [[ "$@" == *"--reset"* ]]; then
	cleanHome 	$@
fi
if [[ "$@" == *"--install"* ]]; then
    install 	$@
fi
if [[ "$@" != *"--no-awesome-update"* ]]; then
	awesomeUpdate 	$@
fi
if [[ "$@" == *"--detDefs"* ]]; then
    setDefaults 	$@
fi
symlinks

echo "done!"
