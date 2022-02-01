#!/bin/bash

INSTALL_STR="${INSTALL_STRING_NO_INPUT:-sudo apt install -y}"
PACKAGES="${INSTALL_PACKAGES_STRING:-zsh awesome}"
CWD=$(pwd)
VERBOSE=0
SILENCE=0

# functions prefixed with "__" are internal functions

function __print {
	# if $1 is ignore: always print
	# print message
	if [ "$1" == "ignore" ]; then
		echo "${@:2}"
		return
	fi
	if [ $SILENCE -eq 0 ]; then
		echo $@
	fi
}

function __doCheck {
	# check if sudo is open
	if [ "$(sudo -n uptime 2>&1 | grep "load" | wc -l)" -eq 0 ]; then
		__print ignore "no sudo access (you need persitent sudo)"
		sudo echo "sudo access granted"
		#check again
		if [ "$(sudo -n uptime 2>&1 | grep "load" | wc -l)" -eq 0 ]; then
			exit 1
		fi
	fi
	# cwd
	if [[ ! -d $CWD ]]; then
		__print ignore "Current working directory is invalid" 1>&2
		exit 1
	fi
	# check if script is in cwd
	if [ ! -f "${CWD}/sync.sh" ]; then
		__print ignore "sync.sh not found in ${CWD}" 1>&2
		exit 1
	fi
	# check if dir configfiles exists
	if [ ! -d "${CWD}/configfiles" ]; then
		__print ignore "configfiles directory not found in ${CWD}" 1>&2
		exit 1
	fi
}

function __verbose {
	if [ $VERBOSE -eq 1 ]; then
		__print "[ $@ ]"
		$@
	else
		#$@ 2>&1 > /dev/null #output only errors

		$@ &> /dev/null
	fi
}

function install {
	__print "> $FUNCNAME"
	__print "# installing packages"
	__verbose $INSTALL_STR $PACKAGES
	__print "# installing ohmyzsh"
	__verbose git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
	__verbose cp ~/.zshrc ~/.zshrc.orig
	__print "# installing zsh plugins"
	__verbose git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions	
	__verbose git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	__print "# installing pfetch"
	__verbose git clone https://github.com/dylanaraps/pfetch.git /tmp/dotfiles-pfetch 		
	cd /tmp/dotfiles-pfetch
	sudo mv pfetch /usr/local/bin/
	__verbose rm -rf /tmp/dotfiles-pfetch
	cd $CWD
}

function setDefaults {
	__print "> $FUNCNAME"
	__print "# setting zsh as default shell"
	__verbose sudo chsh -s /bin/zsh $(whoami)
}

function awesomeUpdate {
	__print "> $FUNCNAME"
	__print "# updating awesome-copycats"
	__verbose git clone \
		--recurse-submodules --remote-submodules --depth 1 -j 2 \
		https://github.com/lcpz/awesome-copycats.git /tmp/awesome-copycats
	__verbose mkdir -p ~/.config/awesome
	__verbose cp -r /tmp/awesome-copycats/* ~/.config/awesome
	__verbose rm -rf /tmp/awesome-copycats
}

function files {
	__print "> $FUNCNAME"
	for file in $(find ./configfiles/ -type f); do
		__print "# linking ${file##*/}"
		__verbose ln -sf $CWD/$file ~/${file#./configfiles/}
	done
}

function clean {
	__print "> $FUNCNAME"
	__print "# cleaning awesome-copycats tmp dir"
	__verbose rm -rf /tmp/awesome-copycats
	__print "# cleaning pfetch tmp dir"
	__verbose rm -rf /tmp/dotfiles-pfetch

	for file in $(find ./configfiles/ -type f); do
		__print "# removing ${file}"
		__verbose rm ~/${file#./configfiles/}
	done
}

################################################################################

if [[ "$@" == *"--silent"* ]]; then
	SILENCE=1
	VERBOSE=0
fi

if [[ "$@" == *"-v"* ]]; then
	SILENCE=0
	VERBOSE=1
fi

# skipCheck
if [[ "$@" == *"--skip-check"* ]]; then
	__print "skipping check"
else
	__doCheck
fi

run=($@)
args=()

# remove any arguments that have a leading '-' or '--' and add them to args
for argument in "${run[@]}"; do
	if [[ $argument == -* ]]; then
		args+=("$argument")
		run=(${run[@]//$argument})
	fi
done

# if no functions are left, run default
if [ ${#run[@]} -eq 0 ]; then
	run=(install awesomeUpdate files setDefaults)
fi

# remove functions that are defined in args like "--no-**"
for (( i=0; i<${#args[@]}; i++ )); do
	for (( j=0; j<${#run[@]}; j++ )); do
		if [[ ${args[$i]} == --no-${run[$j]} ]]; then
			unset run[$j]
		fi
	done
done

#run functions
for i in "${run[@]}"; do
	if [ $SILENCE -eq 1 ]; then
		$i > /dev/null 2>&1
	else
		$i
	fi
done