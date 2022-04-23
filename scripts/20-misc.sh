#!/bin/sh



linkFiles () {
  # link to ~/.config/$1/
  for file in $(find ./files/$1 -type f); do
    __print "# linking ${file}"
    __verbose mkdir -p ~/.config/$1
    __verbose ln -sf $file ~/.config/$1/$(basename $file)
  done
}

configAvail="awesome kitty nvim"

_script_main () {
  for c in $configAvail; do
    linkFiles $c
  done
}

_script_clean () {
  for c in $configAvail; do
    for file in $(find ./files/$c -type f); do
      __print "# removing ${file}"
      __verbose rm -f ~/.config/$c/${file#./files/$c/}
    done
  done
}