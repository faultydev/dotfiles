#!/bin/bash

#variable VERBOSE is set to env var "V" or it will be set to 0
VERBOSE=${V:-0}
SILENCE=${SILENT:-0}

# functions prefixed with "__" are internal functions

function __print {
	# if $1 is ignore: always print
	# print message
	if [ "$1" == "ignore" ]; then
		echo "${@:2}"
		return
	fi
	if [ $SILENCE -eq 0 ]; then
		echo $@
	fi
}

function __verbose {
	# if VERBOSE = 2, only print

	if [ $VERBOSE -eq 0 ]; then
		#$@ 2>&1 > /dev/null #output only errors

		$@ &> /dev/null
		return
	fi
	if [ $VERBOSE -eq 1 ]; then
		__print "[ $@ ]"
		$@
		return
	fi
	if [ $VERBOSE -eq 2 ]; then
		echo "[ dry: $@ ]"
		return
	fi
}

__print "# cloning dotfiles"
__verbose git clone https://github.com/faultydev/dotfiles /tmp/dotfiles
__verbose cd /tmp/dotfiles

__print "# executing sync.sh"
__verbose bash sync.sh

__print "# cleaning up"
__verbose rm -rf /tmp/dotfiles

__print "OK"
exit 0