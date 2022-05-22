#!/bin/sh

CWD=$(pwd)
VERBOSE=0
SILENCE=0
DEBUG=0
USE_TRAPS=${USE_TRAPS:-1}
LOG_FILE=${LOG_FILE:-/dev/null}

VERSION="1.1"

set -e

__print () {
	# if $1 is ignore: always print
	# print message
  case $1 in 
    -i|--ignore|ignore)
      shift;
      echo -e "$@"
    ;;
    -d|--debug|debug)
      shift;
      if [ $DEBUG -eq 1 ]; then
        echo -e "$@"
      fi
    ;;
    *)
      if [ "$SILENCE" = "0" ]; then
        echo -e $@
      fi
    ;;
  esac

}

__verbose () {
	if [ "$VERBOSE" = "0" ]; then
		#$@ 2>&1 > /dev/null #output only errors
		$@ > $LOG_FILE 2>&1
	fi
	if [ "$VERBOSE" = "1" ]; then
		__print "\e[1;33m[ \e[0;33m$@\e[1;33m ] \e[0m"
		$@
	fi
	if [ "$VERBOSE" = "2" ]; then
		__print "\e[1;33m[ dry: \e[0;33m$@ \e[1;33m]\e[0m"
	fi
	wait
}

__error () {
  __print -i "\e[1;31m!! \e[0;31mERROR\e[1;31m !!\e[0m"
  __print -i "error code: \e[1;33m$1\e[0m"
  if [ "$2" != "" ]; then __print "\e[0;33m$2\e[0m" ; fi
  if [ "$3" = "fatal" ]; then 
    __print -i "\e[1;31m!! \e[0;31mFATAL\e[1;31m !!\e[0m"
    exit 1
  else
    __print -i "\e[1;31m!! \e[0;31m-----\e[1;31m !!\e[0m"
  fi
}

__parseArgs () {
  __parsed="$@"
  # parse tags
  for arg in $__parsed; do

    if [ "${arg:0:1}" = "-" ]; then
      __parsed=$(echo $__parsed | sed "s/$arg//")
    fi

    case $arg in
      -v|--verbose) 
        VERBOSE=1
        __print ignore "\e[1;31m:: \e[0;33mverbose\e[1;33m \e[0m"
        ;;
      -s|--silence) SILENCE=1 ;;
      -g|--graphical) GRAPHICAL=1 ;;
      --dry-run) VERBOSE=2 ;;
      -d) DEBUG=1 ;;
      *) ;;
    esac
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
  #check if root
  if [ "$(id -u)" != "0" ]; then
    #check for sudo/doas/etc session
    if ! $DO_AS_SU -n true; then
      __error sudo_check "sudo session not found, persist is required"
      $DO_AS_SU whoami
      __doSyncCheck
    else
      __print -d ":: DEBUG, sudo session OK"
    fi
  else 
    DO_AS_SU=""
    __print -d ":: DEBUG, root login OK"
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

__gitSync () {
  # check if cwd is git repo
  if [ ! -d "${CWD}/.git" ]; then
    __error git_check "not a git repository"
    return
  fi
  __verbose git pull
}

if [ $USE_TRAPS -eq 1 ]; then
  trap '__print "Interrupted..."; exit' SIGINT SIGTERM
fi