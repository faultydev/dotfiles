#!/bin/sh

source ./cfg.conf
source ./lib.sh

doTar () {
    cd ~
    __print "# creating a tarball of important directories"
    # Documents, Pictures, Music, Videos, code
    __verbose tar -czvf $TAR_NAME \
        --exclude=".git" \
        --exclude=".pio/lib*" \
        --exclude="Documents/Backups" \
        --exclude="node_modules" \
        --exclude="build*" \
        --exclude="dist*" \
        $BACKUP_DIRECTORIES
    __verbose mv $TAR_NAME $CWD
    __print "# done"
    cd $CWD
}

__parseArgs $@

# for every item in run, run it (not an array but string, split by spaces)
for item in $__parsed; do
	__print "> $item"
	$item
done