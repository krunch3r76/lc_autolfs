#!/bin/bash
# invoke with script as from another file inside CMDSROOT
# V1.15

PKGNAME=$(basename $PWD)
CMDSROOT="$LFS/sources/cmds/$PKGNAME"
CMDSDIR="$CMDSROOT/.cmds"
CMDSRUNFP="$CMDSROOT/cmdsrun"
IGNORE_ERRORS=0
OPT=$1

set -e
if [[ "$OPT" == "ignore" ]]; then
	IGNORE_ERRORS=1
fi
TOGGLECOLOR1="\033[32m"
TOGGLECOLOR2="\033[33m"
TOGGLECOLOR=$TOGGLECOLOR2
if [[ -e $CMDSRUNFP ]]; then
	rm $CMDSRUNFP
fi


runscript() {
	# todo actually run the script program
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
		echo "ABOUT TO SUDO"
		srcmd="sudo -E"
	fi

	echo -e "$TOGGLECOLOR" >>$CMDSRUNFP
	cat $CMDSDIR/$sourcefile >>$CMDSRUNFP
	echo -e "\033[0m" >>$CMDSRUNFP

	$srccmd $CMDSDIR/$sourcefile
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


try() {
	if [[ "$TOGGLECOLOR" == "$TOGGLECOLOR1" ]]; then
		TOGGLECOLOR=$TOGGLECOLOR2
	else
		TOGGLECOLOR=$TOGGLECOLOR1
	fi
	set +e
	# echo -e "$TOGGLECOLOR$2 $1\033[0m" | sed 's/\t/\n\t/g' 1>&3
	bash -c "$1"
	if [[ $? != 0 ]]; then
		if [[ $2 != "ignore" ]]; then
			echo -ne "\033[1m"
			echo -e "Error running '$1'"
			exit 1
		else
			echo -ne "\033[2m"
			echo "Ignoring error while trying '$1'"
		fi
		echo -ne "\033[0m"
	fi
	set -e
}

try_cmds() {
	local STEP=$STEP
	PREFIXCMD=""
	if [[ $1 == "nostep" ]]; then
		STEP=0
	elif [[ $1 == "sudo" ]]; then
		PREFIXCMD="sudo "
	elif [[ $1 == "step" ]]; then
		STEP=1
	else
		echo "ERROR CALLING FUNCTION TRY_CMDS"
		exit 1
	fi

	shift
	declare -a CMDS
	CMDS=("$@")
	for CMD in "${CMDS[@]}"; do
		if [[ "$STEP" == 1 ]]; then
			echo -e "next command:\n$(echo -e "${PREFIXCMD}${CMD}" | sed -E 's/\t/\n\t/g')" 
			# echo -e "next command:\n$CMD\n"
			set +e
			read -t 10
			set -e
		fi
		try "${PREFIXCMD}${CMD} $ARG"
	done
}

PATCHCMDS=$(find $CMDSDIR -name "patchcmd*" | sort -V)
if [[ -n "$PATCHCMDS" ]]; then
	for cmd in $PATCHCMDS; do
		runscript $(basename $cmd)
	done
else
	NOCOMMANDS=1
fi

CMDS=$(find $CMDSDIR -name "cmd*" | sort -V)
if [[ -n "$CMDS" ]]; then
	for cmd in $CMDS; do
		runscript $(basename $cmd)
	done
else
	echo -e "\033[1mWARNING: no initial commands are in this package\033[0m"
	NOCOMMANDS=1
fi

TCMDS=$(find $CMDSDIR -name "tcmd*" | sort -V)
IGNORE_ERRORS_SAVE=$IGNORE_ERRORS
IGNORE_ERRORS=1
if [[ -n $TCMDS ]]; then
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
		# sed -E -i 's/^([[:space:]]*)(ln -)([^f])(.*)/\1\2f\3\4/g' $scmd
		runscript $(basename $scmd) "sudo"
	done
else
	echo -e "\033[1mWARNING: no super/install commands are in this package\033[0m"
fi

PCMDS=$(find $CMDSDIR -name "pcmd*" | sort -V)
if [[ -n "$PCMDS" ]]; then
	NOCOMMANDS=0
	for pcmd in $PCMDS; do
		runscript $(basename $pcmd) "sudo"
	done
fi

if [[ $NOCOMMANDS == 0 ]]; then
	set +e
	read -t10 -p "in 10 s $PKGNAME will be recorded in the install journal"
	set -e
	echo ""
	echo $PKGNAME >> $LFS/sources/journal
else
	exit 1
fi

# read -t10 -p "the build directory will be erased in 10 seconds"
# rm -rf 
