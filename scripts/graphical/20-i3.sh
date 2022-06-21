_script_main () {
  if [ "$WINDOW_MANAGER" = "i3" ]; then
    __detectPackageManager
    if [ -z "$pm" ]; then
      __print "no package manager"
      return 1
    fi
    __print "installing i3 with $pm"
    __verbose $DO_AS_SU $pm $pm_install $pm_noprompt i3 light dmenu 

  fi

}

_script_update () {
  __print "no update"
}

_script_clean () {
  __verbose $DO_AS_SU $pm $pm_remove $pm_noprompt i3
}