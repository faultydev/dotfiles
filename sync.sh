#!/bin/sh

INSTALL_STR="${INSTALL_STRING_NO_INPUT:-sudo apt install -y}"
PACKAGES="${INSTALL_PACKAGES_STRING:-zsh awesome nvim kitty}"
CWD=$(pwd)
VERBOSE=0
SILENCE=0

# functions prefixed with "__" are internal functions

__print () {
	# if $1 is ignore: always print
	# print message
	if [ "$1" = "ignore" ]; then
		echo "$@" | cut -c8-
		return
	fi
	if [ $SILENCE = 0 ]; then
		echo $@
	fi
}

__verbose () {
	if [ "$VERBOSE" = "0" ]; then
		#$@ 2>&1 > /dev/null #output only errors
		$@ > /dev/null 2>&1
	fi
	if [ "$VERBOSE" = "1" ]; then
		__print "[ $@ ]"
		$@
	fi
	if [ "$VERBOSE" = "2" ]; then
		echo "[ dry: $@ ]"
	fi
	wait
}

__doCheck (){
	# check if sudo is open
	if [ "$(sudo -n uptime 2>&1 | grep "load" | wc -l)" -eq 0 ] && [ "$1" != "-v" ]; then
    __print ignore "no sudo access (you need persitent sudo)"
    sudo echo "sudo access granted"
    #check again
    if [ "$(sudo -n uptime 2>&1 | grep "load" | wc -l)" -eq 0 ]; then
      exit 1
		fi
	fi
	# cwd
	if [ ! -d $CWD ]; then
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
	# check for git
	if [ ! -x "$(which git)" ]; then
		__print ignore "git not found, added to packages" 1>&2
		PACKAGES="${PACKAGES} git"
	fi
}

install () {
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

setDefaults () {
	__print "# setting zsh as default shell"
	__verbose sudo chsh -s /bin/zsh $(whoami)
}

systemEdits () { # sets defaults for system level
  __print "# disabling the hardware speaker (beep)"
  sudo echo "blacklist pcspkr" >> /etc/modprobe.d/blacklist
}

awesomeUpdate () {
	__print "# updating awesome-copycats"
	__verbose git clone \
		--recurse-submodules --remote-submodules --depth 1 -j 2 \
		https://github.com/lcpz/awesome-copycats.git /tmp/awesome-copycats
	__verbose mkdir -p ~/.config/awesome
	__verbose cp -r /tmp/awesome-copycats/* ~/.config/awesome
	__verbose rm -rf /tmp/awesome-copycats
}

files () {
	for file in $(find ./configfiles/ -type f); do
		__print "# linking ${file##*/}"
		__verbose ln -sf $CWD/$file ~/${file#./configfiles/}
	done
}

clean () {
	__print "# cleaning awesome-copycats tmp dir"
	__verbose rm -rf /tmp/awesome-copycats
	__print "# cleaning pfetch tmp dir"
	__verbose rm -rf /tmp/dotfiles-pfetch

	for file in $(find ./configfiles/ -type f); do
		__print "# removing ${file}"
		__verbose rm ~/${file#./configfiles/}
	done
}

empty () {
	__print "# empty function #"
}

################################################################################

run="$@"

# parse tags
for arg in $run; do
	if [ "$arg" = "-v" ]; then
		VERBOSE=1
		__print ignore "verbose mode"
		run=$(echo $run | sed "s/$arg//")
	fi
	if [ "$arg" = "-s" ]; then
		SILENCE=1
		run=$(echo $run | sed "s/$arg//")
	fi
done

# if no items in run, run def
if [ -z "$run" ]; then
	run="install awesomeUpdate files setDefaults"
fi

__doCheck $1

# for every item in run, run it (not an array but string, split by spaces)
for item in $run; do
	__print "> $item"
	$item
done
