#!/bin/bash

function cleanHome {
	echo "> cleanHome"
	rm -rf ~/.config/awesome 	&> /dev/null
	rm -rf ~/.zshrc			&> /dev/null
}

function clean {
	echo "> clean"
	rm -rf /tmp/awesome-copycats &> /dev/null
}

function awesomeUpdate {
	echo "> awesomeUpdate"
	git clone \
                --recurse-submodules --remote-submodules --depth 1 -j 2 \
                https://github.com/lcpz/awesome-copycats.git /tmp/awesome-copycats \
		&> /dev/null
        mkdir -p ~/.config/awesome
        mv /tmp/awesome-copycats ~/.config/awesome
        cp ./configfiles/awesome-rc.lua ~/.config/awesome/rc.lua
        rm -rf /tmp/awesome-copycats
}

function symlinks {
	echo "> symlinks"
	ln -s configfiles/zshrc ~/.zshrc
}

git fetch

clean
if [[ "$@" == *"--reset"* ]]; then
        cleanHome
fi
if [[ "$@" != *"--no-awesome-update"* ]]; then
	awesomeUpdate
fi
symlinks

echo "done!"
