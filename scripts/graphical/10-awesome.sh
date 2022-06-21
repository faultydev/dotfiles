
installAwesome () {
  __detectPackageManager
  __print "# installing awesome"
  if [ -z "$pm" ]; then
    __print "# no package manager found"
    return 1
  fi
  __print "# installing awesome via $pm"
  __verbose $DO_AS_SU $pm $pm_install $pm_noprompt awesome
}

_script_main () {
  if [ "$WINDOW_MANAGER" = "awesome" ]; then
    installAwesome
    _script_update
  fi
}

_script_update () {
  __print "# updating awesome-copycats"
  __verbose git clone \
    --recurse-submodules --remote-submodules --depth 1 -j 2 \
    https://github.com/lcpz/awesome-copycats.git /tmp/awesome-copycats
  __verbose mkdir -p ~/.config/awesome
  __verbose cp -r /tmp/awesome-copycats/* ~/.config/awesome
  __verbose rm -rf /tmp/awesome-copycats
}
_script_clean () {
  __print "# cleaning awesome-copycats"
  __verbose rm -rf ~/.config/awesome
  __print "# uninstalling awesome"
  __detectPackageManager
  __verbose $DO_AS_SU $pm $pm_remove awesome
}