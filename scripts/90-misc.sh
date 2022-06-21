#!/bin/sh

linkFiles () {
  # link to ~/.config/$1/
  for file in $(find ./files/$1 -type f); do
    __print "# linking ${file}"
    __verbose mkdir -p ~/.config/$1
    __verbose chmod +rx $file
    __verbose ln -sf $CWD/$file ~/.config/$1/$(basename $file)
  done
}

configAvail="awesome i3 kitty nvim"

_script_main () {
  for c in $configAvail; do
    linkFiles $c
  done
}

_script_update () {
  _script_main
}

_script_clean () {
  for c in $configAvail; do
    __print "# cleaning $c"
    __verbose rm -rf ~/.config/$c
  done
}