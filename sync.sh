#!/bin/sh

. ./cfg.sh
. ./lib.sh

# ---------- ------ ---------- #
# Version:   1.1 | Fine Line
# Last edit: 20th of May
# ---------------------------- #

pm_packages () {
	__print "# identifying package manager"
	__detectPackageManager
	__print "# installing packages ($PACKAGES) via $pm"
	__verbose $DO_AS_SU $pm $pm_install $pm_noprompt $PACKAGES
}

ext_packages () {
	__print "# installing external packages"

	if [ ! -d ~/.oh-my-zsh ]; then
		__print "# installing ohmyzsh"
		__verbose git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
		__verbose cp ~/.zshrc ~/.zshrc.orig
	fi


	__print "# installing zsh plugins"
	if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]; then
		__verbose git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	fi 
	if [ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]; then
		__verbose git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	fi

	__print "# installing pfetch"
	__verbose git clone https://github.com/dylanaraps/pfetch.git /tmp/dotfiles-pfetch
	__verbose cd /tmp/dotfiles-pfetch
	__verbose $DO_AS_SU mv pfetch /usr/local/bin/
	__verbose rm -rf /tmp/dotfiles-pfetch
	__verbose cd $CWD

}

setDefaults () {
	__print "# setting \e[1;35mzsh\e[0m as default shell"
	if [ "$SHELL" != "/bin/zsh" ]; then
		__verbose $DO_AS_SU chsh -s /bin/zsh $(whoami)
	fi

	__print "# setting up \e[1;32mgit\e[0m"
	__verbose git config --global user.name $GIT_USER_NAME
	__verbose git config --global user.email $GIT_USER_EMAIL
	__verbose git config --global core.editor "vim"
	if [ $GPG_SIGNING_KEY ]; then
		__verbose git config --global commit.gpgsign true
		__verbose git config --global user.signingkey $GPG_SIGNING_KEY
	fi
}

## deprecated; use scripts
files () {
	__print "!! \e[1;31mDEPRECATED\e[0m !! \e[1;33muse scripts function instead\e[0m"
	for file in $(find ./configfiles/ -type f); do
		__print "# linking \e[1;32m$file\e[0m"
		__verbose mkdir -p ~/${file%/*}
		__verbose ln -sf $CWD/$file ~/${file#./configfiles/}
	done
}

## this is the replacement for files
scripts () {
	# only 1 level
	for script in $(find ./scripts/ -maxdepth 1 -type f | sort -n); do
		__print "\e[0;33m>> running ${script##*/}\e[0m"
		. $CWD/$script
		_script_main $@
		__print "\e[0;32m>> done ${script##*/}\e[0m"
	done
	# if $GRAPHICAL is set to 1, do it again but in ./scripts/graphical
	if [ $GRAPHICAL -eq 1 ]; then
		for script in $(find ./scripts/graphical/ -maxdepth 1 -type f | sort -n); do
			# __print ">> running [GRAPHICAL] ${script##*/}"
			__print "\e[0;33m>> running \e[1;33m[GRAPHICAL] \e[0;33m${script##*/}\e[0m"
			. $CWD/$script
			_script_main $@
			# __print ">> finished [GRAPHICAL] ${script##*/}"
			__print "\e[0;32m>> finished \e[1;33m[GRAPHICAL] \e[0;32m${script##*/}\e[0m"
		done
	fi
}

clean () {
	__print "# cleaning awesome-copycats tmp dir"
	__verbose rm -rf /tmp/awesome-copycats
	
	__print "# cleaning pfetch tmp dir"
	__verbose rm -rf /tmp/dotfiles-pfetch

	for script in $(find ./scripts/ -type f -maxdepth 1 | sort -n); do
		__print "\e[0;33m>> cleaning ${script##*/}\e[0m"
		. $CWD/$script
		_script_clean
		__print "\e[0;32m>> done ${script##*/}\e[0m"
	done
	
	if [ $GRAPHICAL -eq 1 ]; then
		for script in $(find ./scripts/graphical/ -type f -maxdepth 1 | sort -n); do
			__print "\e[0;33m>> cleaning \e[1;33m[GRAPHICAL] \e[0;33m${script##*/}\e[0m"
			. $CWD/$script
			_script_clean
			__print "\e[0;32m>> finished \e[1;33m[GRAPHICAL] \e[0;32m${script##*/}\e[0m"
		done
	fi

	__print "# cleaning applications"
	__detectPackageManager
	__verbose $DO_AS_SU $pm $pm_remove $pm_noprompt $PACKAGES
}

full_clean () {
	__print "\e[2;37m> clean\e[0m"
	clean
	__print "\e[2;37mcontinue > full_clean\e[0m"

	if [ ! -d ~/.local/dotfiles ]; then
		__print "\e[1;31m!! ~/.local/dotfiles does not exist\e[0m"
		return 1
	fi

	__print "# removing dotfiles dir"
	__verbose rm -rf ~/.local/dotfiles

	__print "\e[1;32m Goodbye!\e[0m"
}

empty () {
	__print "\e[0;33m## empty ##\e[0m"
}

falseError () {
	__print "test error"
	# run command that should fail
	__verbose which idontexist
}

####

__parseArgs $@
run="$__parsed"

# if no items in run, run def
if [ -z "$run" ]; then
	run="pm_packages ext_packages setDefaults scripts"
fi
__doSyncCheck $1

# for every item in run, run it (not an array but string, split by spaces)
for item in $run; do
	# gray text
	__print "\e[2;37m> $item\e[0m"
	$item
done