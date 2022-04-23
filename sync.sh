#!/bin/sh

. ./cfg.sh
. ./lib.sh

# April-22 Version
# Last edit: 14th of April

####

pm_packages () {
	__print "# identifying package manager"
	__detectPackageManager
	__print "# installing packages ($PACKAGES) via $pm"
	__verbose $DO_AS_SU $pm $pm_install $pm_noprompt $PACKAGES
}

ext_packages () {
	__print "# installing external packages"

	__print "# installing ohmyzsh"
	__verbose git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
	__verbose cp ~/.zshrc ~/.zshrc.orig

	__print "# installing zsh plugins"
	__verbose git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	__verbose git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

	__print "# installing pfetch"
	__verbose git clone https://github.com/dylanaraps/pfetch.git /tmp/dotfiles-pfetch
	__verbose cd /tmp/dotfiles-pfetch
	__verbose $DO_AS_SU mv pfetch /usr/local/bin/
	__verbose rm -rf /tmp/dotfiles-pfetch
	__verbose cd $CWD

}

setDefaults () {
	__print "# setting zsh as default shell (if not already)"
	if [ "$SHELL" != "/bin/zsh" ]; then
		__verbose $DO_AS_SU chsh -s /bin/zsh $(whoami)
	fi
	__print "# setting tap to click (for laptops)"
	__verbose xinput set-prop 'ALP0016:00 044E:1215' 'libinput Tapping Enabled' 1
	__print "# setting up natural scolling"
	__verbose xinput set-prop 'ALP0016:00 044E:1215' 'libinput Natural Scrolling Enabled' 1
}

files () {
	for file in $(find ./configfiles/ -type f); do
		__print "# linking ${file##*/}"
		__verbose mkdir -p ~/${file%/*}
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

####

__parseArgs $@
run="$__parsed"

# if no items in run, run def
if [ -z "$run" ]; then
	run="pm_packages ext_packages setDefaults files"
fi
__doSyncCheck $1

# for every item in run, run it (not an array but string, split by spaces)
for item in $run; do
	__print "> $item"
	$item
done
