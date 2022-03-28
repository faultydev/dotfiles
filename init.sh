#!/bin/sh

echo "### $0 ###"

echo "# cloning dotfiles"
git clone https://github.com/faultydev/dotfiles ~/.dotfiles
cd ~/.dotfiles
echo "# executing sync.sh"
sh sync.sh

echo "### done ###"
exit 0
