#!/bin/bash

function clean {
	rm /tmp/awesome-copycats
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
if [[ $1 != "--no-awesome-update" ]]; then
	awesomeUpdate
fi
symlinks

echo "done!"
