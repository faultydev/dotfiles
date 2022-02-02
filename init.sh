#!/bin/sh

#variable VERBOSE is set to env var "V" or it will be set to 0
VERBOSE=${V:-0}
SILENCE=${SILENT:-0}

# functions prefixed with "__" are internal functions

__print () {
	# if $1 is ignore: always print
	# print message
	if [ "$1" = "ignore" ]; then
		echo "${@:2}"
		return
	fi
	if [ $SILENCE = 0 ]; then
		echo $@
	fi
}

__verbose () {
	if [ $VERBOSE -eq 0 ]; then
		#$@ 2>&1 > /dev/null #output only errors

		$@ &> /dev/null
	fi
	if [ $VERBOSE -eq 1 ]; then
		__print "[ $@ ]"
		$@
	fi
	if [ $VERBOSE -eq 2 ]; then
		echo "[ dry: $@ ]"
	fi
	wait
}

__print "# cloning dotfiles"
__verbose git clone https://github.com/faultydev/dotfiles ~/.dotfiles
__verbose cd ~/.dotfiles
__print "# executing sync.sh"
__verbose sh sync.sh

__print "OK"
exit 0
