#!/bin/bash
# invoke with binary script as from another file (install.sh) inside CMDSROOT
# V1.20=1

PKGNAME=$(basename $PWD)
CMDSROOT="$LFS/sources/cmds/$PKGNAME"
CMDSDIR="$CMDSROOT/.cmds"
CMDSRUNFP="$CMDSROOT/cmdsrun"
IGNORE_ERRORS=0
IGNORE_POST_ERRORS=0
OPT=$1

set -e
if [[ "$OPT" == "ignore" ]]; then
	IGNORE_ERRORS=1
elif [[ "$OPT" == "ignorepost" ]]; then
	IGNORE_POST_ERRORS=1
fi
TOGGLECOLOR1="\033[32m"
TOGGLECOLOR2="\033[33m"
TOGGLECOLOR=$TOGGLECOLOR2
if [[ -e $CMDSRUNFP ]]; then
	rm $CMDSRUNFP
fi


runscript() {
	sourcefile=$1
	sudo=$2
	echo -e "\033[0;0"
	if [[ "$TOGGLECOLOR" == "$TOGGLECOLOR1" ]]; then
		TOGGLECOLOR=$TOGGLECOLOR2
	else
		TOGGLECOLOR=$TOGGLECOLOR1
	fi
	set +e
	echo -e "$TOGGLECOLOR"
	cat $CMDSDIR/$sourcefile
	echo -en "\033[0;1m"
	read -t 10 -p "enter to run the above command"
	echo -e "\033[0m"


	srccmd="source"
	if [[ -v $sudo ]]; then
		if command -v sudo >/dev/null; then
			echo "ABOUT TO SUDO"
			sudocmd() { sudo -E bash -c "source \"$1\""; }
			srccmd=sudocmd
			# srccmd="sudo -E bash -c source"
		fi
	fi

	echo -e "$TOGGLECOLOR" >>$CMDSRUNFP
	cat $CMDSDIR/$sourcefile >>$CMDSRUNFP
	echo -e "\033[0m" >>$CMDSRUNFP

	$srccmd "$CMDSDIR/$sourcefile"
	if [[ $? != 0 ]]; then
		echo -e "\033[1m" >>$CMDSRUNFP
		echo "cmd failed"
		echo "cmd failed" >>$CMDSRUNFP
		echo -e "\033[0m"
		echo -e "\033[0m" >>$CMDSRUNFP
		if [[ $IGNORE_ERRORS != 1 ]]; then
			exit 1
		fi
	fi
	echo "" >> $CMDSRUNFP
	set -e
	echo -e "$?\n"
	echo -e "\033[0m"
	echo -e "\033[0m" >>$CMDSRUNFP
}


NOCOMMANDS=1
PATCHCMDS=$(find $CMDSDIR -name "patchcmd*" | sort -V)
if [[ -n "$PATCHCMDS" ]]; then
	NOCOMMANDS=0
	for cmd in $PATCHCMDS; do
		runscript $(basename $cmd)
	done
fi

CMDS=$(find $CMDSDIR -name "cmd*" | sort -V)
if [[ -n "$CMDS" ]]; then
	NOCOMMANDS=0
	for cmd in $CMDS; do
		runscript $(basename $cmd)
	done
else
	echo -e "\033[1mWARNING: no initial commands are in this package\033[0m"
fi

TCMDS=$(find $CMDSDIR -name "tcmd*" | sort -V)
IGNORE_ERRORS_SAVE=$IGNORE_ERRORS
IGNORE_ERRORS=1
if [[ -n $TCMDS ]]; then
	NOCOMMANDS=0
	if [[ "$OPT" != "skiptests" ]]; then
		for tcmd in $TCMDS; do
			runscript $(basename $tcmd)
		done
	else
		echo "skipping tests"
	fi
fi
IGNORE_ERRORS=$IGNORE_ERRORS_SAVE


SCMDS=$(find $CMDSDIR -name "scmd*" | sort -V)
if [[ -n "$SCMDS" ]]; then
	NOCOMMANDS=0
	for scmd in $SCMDS; do
		runscript $(basename $scmd) "sudo"
	done
else
	echo -e "\033[1mWARNING: no super/install commands are in this package\033[0m"
fi


PCMDS=$(find $CMDSDIR -name "pcmd*" | sort -V)
if [[ $IGNORE_POST_ERRORS != 0 ]]; then
	echo -e "\033[1mignoring errors on post configuration commands\033[0m"
fi
IGNORE_ERRORS_SAVE=$IGNORE_ERRORS
IGNORE_ERRORS=$IGNORE_POST_ERRORS
if [[ -n "$PCMDS" ]]; then
	NOCOMMANDS=0
	for pcmd in $PCMDS; do
		runscript $(basename $pcmd) "sudo"
	done
fi
IGNORE_ERRORS=$IGNORE_ERRORS_SAVE

if [[ $NOCOMMANDS == 0 ]]; then
	set +e
	read -t10 -p "in 10 s $PKGNAME will be recorded in the install journal"
	set -e
	echo ""
	echo $PKGNAME >> $LFS/sources/journal
else
	exit 1
fi
