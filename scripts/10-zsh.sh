#!/bin/sh

# this will setup the files for ZSH
# all files from ./files/zsh/ need to be in ~/

# relative to ./files/zsh/
lnFiles=".zshrc .zsh_scripts"
cpFiles=".zsh_preferences"

linkFiles () {
  # link to ~/
  for file in $lnFiles; do
    __print "# linking ${file}"
    __verbose mkdir -p ~/
    __verbose ln -sf $CWD/files/zsh/$file ~/$file
  done
}

copyFiles () {
  # copy to ~/
  for file in $cpFiles; do
    __print "# copying ${file}"
    __verbose mkdir -p ~/
    __verbose cp $CWD/files/zsh/$file ~/$file
  done
}

_script_main () {
  linkFiles
  copyFiles
}

_script_clean () {
  for file in $lnFiles; do
    __print "# removing ${file}"
    __verbose rm -f ~/${file#./files/zsh/}
  done
  for file in $cpFiles; do
    __print "# removing ${file}"
    __verbose rm -f ~/${file#./files/zsh/}
  done
}