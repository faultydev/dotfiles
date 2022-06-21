#!/bin/sh

CWD=$(pwd)
LOG_FILE=${LOG_FILE:-/dev/null}
VERBOSE=0
SILENCE=0
DEBUG=0

VERSION="2.0"

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
    -r|--raw)
      shift;
      echo -e -n "$@"
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
  __print -i "error: \e[1;33m$1\e[0m"
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
  if [ $USE_SUDO = 1 ]; then
    #check if root
    if [ "$(id -u)" != "0" ]; then
      #check for sudo/doas/etc session
      if ! $DO_AS_SU -n true; then
        __error "sudo_check \e[0m@ $LINENO" "sudo session not found, persist is required"
        __print -d ":: DEBUG, $DO_AS_SU whoami: $($DO_AS_SU whoami)"
        __doSyncCheck
        return
      else
        __print -d ":: DEBUG, sudo session OK"
      fi
    else 
      DO_AS_SU=""
      __print -d ":: DEBUG, root login OK"
    fi
  fi

	# cwd
	if [ ! -d $CWD ]; then
		__print ignore "Current working directory is invalid" 1>&2
		exit 1
  else
    __print -d ":: DEBUG, cwd OK"
	fi
	
  # TODO: fix in 2.0 {
  # check if script is in cwd
	if [ ! -f "${CWD}/sync.sh" ]; then
		__print ignore "sync.sh not found in ${CWD}" 1>&2
		exit 1
  else
    __print -d ":: DEBUG, sync.sh found in cwd"
	fi
	
  # check if dir configfiles exists
	if [ ! -d "${CWD}/files" ]; then
		__print ignore "configfiles directory not found in ${CWD}" 1>&2
		exit 1
	fi
  # }
	
  # check for git
	if [ ! -x "$(which git)" ]; then
		__print "# git not found, added to packages" 1>&2
		PACKAGES="${PACKAGES} git"
	fi
}

__gitSync () {
  __print -r ":: \e[1;32mGit\e[0m | checking for updates"
  # check if cwd is git repo
  if [ ! -d "${CWD}/.git" ]; then
    __error git_check "not a git repository"
    return
  fi
  # get current hash
  CURRENT_HASH=$(git rev-parse HEAD)
  __verbose git pull origin master
  if [ "$CURRENT_HASH" != "$(git rev-parse HEAD)" ] || [ "$1" = "--test" ]; then
    __print -r "\r:: \e[1;32mGit \e[0m|\e[1;32m updated\e[0m"
    __print -r "\n:: \e[0;33mPlease restart the script.\e[0m"
    exit 0
  else
    __print -r "\r:: \e[1;32mGit \e[0m|\e[1;33m no changes\e[0m          \n"
  fi
}

trap '__print ignore "Interrupted..."; exit' SIGINT SIGTERM
trap 'if [ $? -ne 0 ]; then __error non_zero_exit "an error occured" fatal; fi' ERR EXIT