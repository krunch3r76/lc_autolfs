#!/bin/bash
# V1.6

PKGNAME=$(basename $PWD)
SRCDIR=$PWD
PKGDIR=$LFS/sources/$PKGNAME
if [[ ! -d $PKGDIR ]]; then
	echo "$PKGDIR does not exist! ABORTING"
	exit 1
fi
OPT=$1
cd $PKGDIR
set +o noclobber
script -e -q -c "$SRCDIR/_install.sh $OPT" "$SRCDIR/script"

CODE=$?
if [[ $CODE == 0 && "$OPT" != "nowipe" ]]; then
	read -t10 -p "the package build directory at $PKGDIR will be wiped in 10 secs"
	rm -rf $PKGDIR
else
	echo -e "\033[1m"\
		"error (code $CODE)" \
	"!\033[0m"
fi
echo ""

