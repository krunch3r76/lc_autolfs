# lc_autolfs
scripting the lfs package installation

or scripting the lfs book package installation instructions

don't know what lfs is? then you don't know the meaning of free: https://www.linuxfromscratch.org

the problem lc_autolfs solves is when installing a base lfs system, it is easy to overlook what packages or commands may have been skipped or may have failed. lc_autolfs solves this problem by facilitating an automated workflow to install and review. this is accomplished primarily by mentally categorizing the commands from the instructions pages before writing them out, writing them in their entirety before running them, and executing the commands in order automated to capture exit codes _and_ via the script binary (from util-linux) to record the outputs.

# USAGE
refer to https://www.linuxfromscratch.org/lfs/view/stable/chapter08/sysklogd.html to follow along with the examples

## add script to the chroot env and clone the repo
__if _script_ is already installed in the chroot environment, the statement to copy script from the host to $LFS/sources/bin may be omitted__
```bash
(host)# mount $LFS
(host)$ mkdir -p $LFS/sources/bin # this will be added to the path when sourcing later
(host)$ cp /usr/bin/script $LFS/sources/bin
(host)$ cd $LFS/sources
(host) ($LFS/sources)$ #wget tarbells
(host) ($LFS/sources)$ git clone https://github.com/krunch3r76/lc_autolfs
(host) ($LFS/sources)$ cd lc_autolfs
(host) ($LFS/sources/lc_autolfs)$ git checkout v0.1.0
```

## chroot into $LFS
next chroot into $LFS as per the manual directions (mount proc as needed beforehand)

## source needed environment variables
```bash
(chroot) /# cd /sources/lc_autolfs
(chroot) /sources/lc_autolfs# source s_f
```

## untar desired package (repeat for subsequent packages here)
```
(chroot) /sources/lc_autolfs# cd /sources
(chroot) /sources# tar -xf sysklogd-1.5.1.tar.gz
(chroot) /sources# cd sysklogd-1.5.1
(chroot) /sources/sysklogd-1.5.1# mklfscmd
# comments: 1.copies skeleton files from cmdskeleton repo dir to corresponding /sources/cmds/<pkgname> dir
#2.creates a .cmds dir there
#3.changes directory to there (.cmds directory under /sources/cmds/<pkgname>)
(chroot) /sources/cmds/sysklogd-1.5.1/.cmds#
```

## copy and paste instructions from lfs manual page into text files
lfs instructions may be categorized in order as patch commands, configuration/build commands, installation commands, and post-configuration commands.
here in /sources/cmds/sysklod-1.5.1/.cmds we create text files for these categories to be run as shell commands in the priority implied.

### create text files that contain the instructions for patching: patchcmd{1,2,3,...}
in the sysklogd-1.5.1 manual page there are none, otherwise we would create patchcmd1,2,3 files. they may be omitted here.

### create text files that contain build/configuration instructions: cmd{1,2,3...}
we will create the first command(s) to be run as a text file cmd1. if there was a patch command to run, it would be named patchcmd1 and would be run first later. as, there are not patch commands, we begin by creating a configuration/build command text file cmd1:
```bash
(chroot) /sources/cmds/sysklogd-1.5.1/.cmds# cat >cmd1
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
^D
```
each command text is run in order from 1,2,3..etc. the manual page for sysklogd's next block is also a configuration/build command, so we create cmd2 to follow cmd1:
```bash
(chroot) /sources/cmds/sysklogd-1.5.1/.cmds# cat >cmd2
make
^D
```
### create text files that contain test instructions: tcmd{1,2,3...}
there are no test commands for the example package but if there were it would follow the same pattern. they may be omitted here.

### create text files that contain install instructions: scmd{1,2,3...}
the next command is an install command, typically make install. this would normally require superuser privileges. it is assumed for now that chroot is running with root privileges, however. to set the commands run as "superuser" we begin with scmd1 and then if needed scmd2 and so on to set up symbolic links etc.
```bash
(chroot) /sources/cmds/sysklogd-1.5.1/.cmds# cat >scmd1
make BINDIR=/sbin install
^D
```

### create text files that contain system configuration instructions: pcmd{1,2,3,...}
next we see there are post configuration commands in the sysklogd manual page. these are copied into pcmd1 (pcmd2 etc if there were more blocks):
```bash
(chroot) /sources/cmds/sysklogd-1.5.1/.cmds# cat >pcmd1
cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF
^D
```

### cd into parent directory and run install script
```bash
(chroot) /sources/cmds/sysklogd-1.5.1/.cmds# cd ..
(chroot) /sources/cmds/sysklogd-1.5.1# ./install.sh
# comments: patchcmds, cmds, tcmds, scmds, and pcmds are run in sequence with brief pauses if interruption desirable
#, output to screen, and logged. the sequence stops if there is an error except for test commands
#(unless ignore passed to script - see options section below)
```

### after a successful run, review
```bash
/sources/cmds/sysklogd-1.5.1# more cmdsruns
/sources/cmds/sysklogd-1.5.1# more script
# tail /sources/journal
```

# USAGE VIDEO DEMOS

this video demonstrates (patchcmd), cmd, scmd, (tcmd), and pcmd for (patch commands), build commands, install commands, (test commands), and post configuration commands respectively. if there were patch commands, patchcmd1,2,3 would have been used or for tests tcmd1,2,3 etc.

https://user-images.githubusercontent.com/46289600/155764359-e4356bfb-6dfc-46d8-8314-be017f6d7a11.mp4


# USAGE TIPS
there is no need to manually press enter to run each command, each command will execute after a short timeout (as long as the previous did not report an error)

to reinstall a package simply untar and run _mklfscmd_ in the package dir. the cmds from before will be preserved and the directory will change as expected to the package cmds directory.

only source _s_f_ once (not needed again)

edit _s_f_ to uncomment the makeflags line to reduce build times, then source. (without an editor, this would be done via the host mount)

after setting up the build environment, it is okay to mv the cmds directory to cmds_build or whatever so that a new cmds directory is used for the next stage (to avoid package name conflicts and retain logs)

any manual page can be scripted even if there is no associated tarbell. the execution will be logged to /sources/journal under whatever directory name mklfscmd was run from.

$LFS/sources/bin might be a good place to write your own scripts, that could wrap these scripts!

## options to install.sh
errors on any commands except test commands will break execution. currently, install.sh accepts a single argument which is either "ignore" or "skiptests". "ignore" will ignore all errors, while normally any error would break the command sequence entirely. "skiptests" will skip running the test commands (if any were specified). more options in the future for more granularity, including skipping post configuration.

### example (substitute sysklogd with whatever package)
```bash
(chroot) /sources/cmds/sysklogd-1.5.1# ./install.sh ignore
(chroot) /sources/cmds/sysklogd-1.5.1# ./install.sh skiptests
```


# COMMENTS
as of this writing this is an MVP. over time, the interface should get less klunky and more candy.

_script_ (part of the util-linux suite of tools) is standard on any linux distribution and the directions to copy from the host should be safely skipped if util-linux of LFS has already been compiled e.g. at: https://www.linuxfromscratch.org/lfs/view/stable/chapter07/util-linux.html.
