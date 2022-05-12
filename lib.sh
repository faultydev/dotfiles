#!/bin/sh

CWD=$(pwd)
VERBOSE=0
SILENCE=0

trap '__print "Exiting..."; exit' SIGINT SIGTERM

__print () {
	# if $1 is ignore: always print
	# print message
	if [ "$1" = "ignore" ]; then
		echo "$@" | cut -c8-
		return
	fi
	if [ "$SILENCE" = "0" ]; then
		echo $@
	fi
}

__verbose () {
	if [ "$VERBOSE" = "0" ]; then
		#$@ 2>&1 > /dev/null #output only errors
		$@ > /dev/null 2>&1
	fi
	if [ "$VERBOSE" = "1" ]; then
		__print "[ $@ ]"
		$@
	fi
	if [ "$VERBOSE" = "2" ]; then
		echo "[ dry: $@ ]"
	fi
	wait
}

__parseArgs () {
  __parsed="$@"
  # parse tags
  for arg in $__parsed; do
    # if [ "$arg" = "-v" ]; then
    #   VERBOSE=1
    #   __print ignore "verbose mode"
    #   __parsed=$(echo $__parsed | sed "s/$arg//")
    # fi
    # if [ "$arg" = "-s" ]; then
    #   SILENCE=1
    #   __parsed=$(echo $__parsed | sed "s/$arg//")
    # fi
    # if [ "$arg" = "--dry-run" ]; then
    #   VERBOSE=2
    #   __parsed=$(echo $__parsed | sed "s/$arg//")
    # fi
    case $arg in
      -v|--verbose) 
        VERBOSE=1
        __print ignore "verbose mode" 
        __parsed=$(echo $__parsed | sed "s/$arg//")
        ;;
      -s|--silence) SILENCE=1; __parsed=$(echo $__parsed | sed "s/$arg//") ;;
      -g|--graphical) GRAPHICAL=1; __parsed=$(echo $__parsed | sed "s/$arg//") ;;
      --dry-run) VERBOSE=2; __parsed=$(echo $__parsed | sed "s/$arg//") ;;
      *) ;;
    esac

    if [ "$arg" = "-"** ]; then
      __parsed=$(echo $__parsed | sed "s/ $arg//")
    fi
  done
}

__detectPackageManager () {
  pm=""
  pm_noprompt=""
  # pacman
  if [ -x "$(which pacman 2>&1)" ]; then
    pm="pacman"
    pm_install="-S"
    pm_remove="-R"
    pm_noprompt="--noconfirm"
  fi
  # apt-get
  if [ -x "$(which apt-get 2>&1)" ]; then
    pm="apt-get"
    pm_install="install"
    pm_remove="purge"
    pm_noprompt="-y"
  fi
  # emerge
  if [ -x "$(which emerge 2>&1)" ]; then
    pm="emerge"
    pm_install=""
    pm_remove="unmerge"
    pm_noprompt="-v"
  fi
  # yum
  if [ -x "$(which yum 2>&1)" ]; then
    pm="yum"
    pm_install="install"
    pm_remove="remove"
    pm_noprompt="-y"
  fi
  # zypper
  if [ -x "$(which zypper 2>&1)" ]; then
    pm="zypper"
    pm_install="install"
    pm_remove="remove"
    pm_noprompt="-y"
  fi
  # dnf
  if [ -x "$(which dnf 2>&1)" ]; then
    pm="dnf"
    pm_install="install"
    pm_remove="remove"
    pm_noprompt="-y"
  fi
  # apk
  if [ -x "$(which apk 2>&1)" ]; then
    pm="apk"
    pm_install="add"
    pm_remove="del"
    pm_noprompt=""
  fi
  # apt-get
  if [ -x "$(which apt-get 2>&1)" ]; then
    pm="apt-get"
    pm_install="install"
    pm_remove="purge"
    pm_noprompt="-y"
  fi

  if [ -z "$pm" ]; then
    # if global variable PM_STR is set, use it
    if [ -n "$PM_STR" ]; then
      pm="${PM_STR}"
      pm_noprompt="${PM_NOPROMPT_STR:-}"
    else
      __print "error: no package manager found"
      exit 1
    fi
  fi
}

__doSyncCheck () {
	# check if sudo is open
	if [ "$(sudo -n uptime 2>&1 | grep "load" | wc -l)" -eq 0 ] && [ "$1" != "-v" ]; then
    __print ignore "no sudo access (you need persitent sudo)"
    sudo echo "sudo access granted"
    #check again
    if [ "$(sudo -n uptime 2>&1 | grep "load" | wc -l)" -eq 0 ]; then
      exit 1
		fi
	fi
	# cwd
	if [ ! -d $CWD ]; then
		__print ignore "Current working directory is invalid" 1>&2
		exit 1
	fi
	# check if script is in cwd
	if [ ! -f "${CWD}/sync.sh" ]; then
		__print ignore "sync.sh not found in ${CWD}" 1>&2
		exit 1
	fi
	# check if dir configfiles exists
	if [ ! -d "${CWD}/files" ]; then
		__print ignore "configfiles directory not found in ${CWD}" 1>&2
		exit 1
	fi
	# check for git
	if [ ! -x "$(which git)" ]; then
		__print ignore "git not found, added to packages" 1>&2
		PACKAGES="${PACKAGES} git"
	fi
}
