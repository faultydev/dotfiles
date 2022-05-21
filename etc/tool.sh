#!/bin/sh

. ../cfg.sh
. ../lib.sh

createBackup () {
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

minify_n_upload () {
  __print "# minifying..."
  ./minify.sh init.sh
  __print "# uploading..."
  scp init.sh.tmp faulty.nl:/srv/www/faulty.nl/.sh
  __print "# removing tmp file..."
  rm init.sh.tmp
}

test () {
  echo $@
}

for arg in $@; do
  case $arg in
    *) 
      __print "\e[2;37m> $arg\e[0m"
      $arg $@
    ;;
  esac
done