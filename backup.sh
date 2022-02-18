#!/bin/sh

###################
# CREATE A BACKUP #
# v1.0            #
###################

ORIGIN_DIR=$(pwd)
VERBOSE=1
SILENCE=0
tarname="backup_$(date +%Y-%m-%d_%H.%M.%S).tar"

# functions prefixed with "__" are internal functions

__print () {
	# if $1 is ignore: always print
	# print message
	if [ "$1" = "ignore" ]; then
		echo "$@" | cut -c8-
		return
	fi
	if [ $SILENCE = 0 ]; then
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

create_tar () {
    cd ~
    __print "creating a tarball of important directories"
    # Documents, Pictures, Music, Videos, code
    __verbose tar -czvf $tarname \
        --exclude=".git" \
        --exclude=".pio/lib*" \
        --exclude="Documents/Backups" \
        --exclude="node_modules" \
        --exclude="build*" \
        --exclude="dist*" \
        Documents Pictures Music Videos code 
    mv $tarname $ORIGIN_DIR
    __print "done"
    cd $ORIGIN_DIR
}

compress () {
    __print "compressing the tarball"
    __verbose xz -z $tarname
    __print "done"
}

#run all args
for i in "$@"; do 
    $i
done