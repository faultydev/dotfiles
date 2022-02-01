#!/bin/bash

INSTALL_STR="${INSTALL_STRING_NO_INPUT:-sudo apt install -y}"
PACKAGES="${INSTALL_PACKAGES_STRING:-zsh awesome}"
CWD=$(pwd)
VERBOSE=0

function __verbose {
	if [ $VERBOSE -eq 1 ]; then
		$@
	else
		#$@ 2>&1 > /dev/null #output only errors

		$@ &> /dev/null
	fi
}

function install {
	echo "> install"
	echo "# installing packages"
	__verbose $INSTALL_STR $PACKAGES
	echo "# installing ohmyzsh"
	curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh 
	echo "# installing zsh plugins"
	__verbose git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions	
	__verbose git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	echo "# installing pfetch"
	__verbose git clone https://github.com/dylanaraps/pfetch.git /tmp/dotfiles-pfetch 		
	cd /tmp/dotfiles-pfetch; sudo make install
	__verbose rm -rf /tmp/dotfiles-pfetch
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
	__verbose rm -rf /tmp/dotfiles-pfetch
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

function links {
	echo "> links"
	__verbose ln configfiles/zshrc ~/.zshrc
}

__verbose git fetch
 
if [[ "$@" == *"-v"* ]]; then
	VERBOSE=1
fi

#array of functions to run (default)
run=(install awesomeUpdate links setDefaults)

# if arguments are given, run only those functions
if [[ $# -gt 0 ]]; then
	run=()
	if [[ "$@" == *"clean"* ]]; then
		run+=(clean cleanHome)
	fi
	if [[ "$@" == *"packages"* ]]; then
		run+=(install)
	fi
	if [[ "$@" == *"awesome-update"* ]]; then
		run+=(awesomeUpdate)
	fi
	if [[ "$@" == *"links"* ]]; then
		run+=(links)
	fi
	if [[ "$@" == *"defaults"* ]]; then
		run+=(setDefaults)
	fi

	# if run is empty, exit
	if [[ ${#run[@]} -eq 0 ]]; then
		echo "No valid arguments given"
		exit 1
	fi
fi

#run functions
for i in "${run[@]}"; do
	$i
done

echo "done!"