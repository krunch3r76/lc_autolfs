# lc_autolfs
scripting the lfs package installations

one problem i have had when installing lfs packages is keeping track or ensuring i ran every command. i wrote a small group of short scripts (short and sweet to audit) to help with this. with my tools, you can review just the commands run or the commands run and their output. you can review the packages installed and in what order (useful if you think you missed one). package names follow the directory name so you can add pass 1 pass 2 etc to whatever you untar. please see the video demo

additionally, once you have written the commands, you can sit back or leave the terminal and review later, they will run by themselves without intervention after a short timeout.

# REQUIREMENTS
the **script** binary (_/usr/bin/script_) from your host should be copied to lfs chroot env and placed in the path at _/sources/bin/_ (**make this directory**)
however, if _/sources/bin/_ does not exist, but **script** has been copied into the path elsewhere, that is fine.
the source tarbells have been downloaded into /sources (e.g. via the wget script)

# INSTALLATION
in $LFS/sources (not in chroot)
```bash
git clone https://github.com/krunch3r76/lc_autolfs
cd lc_autolfs
git checkout v0.0.6
# modify s_f to set makeflags if desired
```

# USAGE VIDEO DEMOS

this video demonstrates (patchcmd), cmd, scmd, (tcmd), and pcmd for build commands, install commands, (test commands), and post configuration commands respectively. if there were patch commands, patchcmd1,2,3 would have been used or for tests tcmd1,2,3 etc. for parenthesized commands see example written.

https://user-images.githubusercontent.com/46289600/155764359-e4356bfb-6dfc-46d8-8314-be017f6d7a11.mp4


# USAGE

## BEGIN
```
in chroot environment, first set up your environment by sourcing s_f in /sources/lc_autolfs
then cd to /sources
untar the package
rename package directory if desired
enter the package directory
run the environment function (previously sourced from s_f) mklfscmd
this will change your directory into a .cmds directory in a separate directory /sources/cmds/<pkg dir name> (made if needed)
cat the commands from the instructions, categorized as follows:
each patch command is:
cat >patchcmd1 ... 2,3,4,...
each build configuration command is:
cat >cmd1 ... 2,3,4 ..
each super user command is:
cat >scmd1 ... 2,3,4 ...
each post configuration command is:
cat >pcmd1 ... 2,3,4 ...
when you have created the command dialogues:
cd ../ into /sources/cmds/<pkg-dir-name>
invoke ./install.sh
```

## POST
a directory under /sources/cmd has been created by running mklfscmd. the name of this directory is _exactly_ the same as that of the source directory at /sources (where one untarr'ed the package).
```
the directory /sources/cmds/<pkg-dir-untarred-to> has been created
/sources/cmds/<pkg-dir-untarred-to>/script # ansi colored alternating commands run and output
/sources/cmds/<pkg-dir-untarred-to>/cmdsrun # ansi colored output of all commands run
/sources/cmds/<pkg-dir-untarred-to>/.cmds # contains the commands that were added to be run
/sources/journal has a line added to it that is the same as <pkg-dir-untarred-to>

to see ansi colors, review with _more_
```

## EXAMPLE (from video)
```bash
(/mnt/lfs/sources) # chroot
(lfs chroot) root:/# cd sources # this is where you downloaded the tars
(lfs chroot) root:/sources# cd lc_autolfs
(lfs chroot) root:/sources/lc_autolfs# source s_f
(lfs chroot) root:/sources/lc_autolfs# cd /sources/
(lfs chroot) root:/sources# tar -xf sysklogd-1.5.1.tar.gz
(lfs chroot) root:/sources# cd sysklogd-1.5.1
(lfs chroot) root:/sources/sysklogd-1.5.1# mklfscmd
mkdir: created directory '/sources/cmds/sysklogd-1.5.1' # chdir happens in the background


(lfs chroot) root:/sources/cmds/sysklogd-1.5.1/.cmds# cat >patchmd1
# if there was a patch command it would be pasted here

(lfs chroot) root:/sources/cmds/sysklogd-1.5.1/.cmds# cat >cmd1
sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
^D

(lfs chroot) root:/sources/cmds/sysklogd-1.5.1/.cmds# cat >cmd2
make
^D

(lfs chroot) root:/sources/cmds/sysklogd-1.5.1/.cmds# cat >tcmd1
# if there was a test command it would be pasted here

(lfs chroot) root:/sources/cmds/sysklogd-1.5.1/.cmds# cat >scmd1
make BINDIR=/sbin install
^D

(lfs chroot) root:/sources/cmds/sysklogd-1.5.1/.cmds# cat >pcmd1
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
see video more added soon


# USAGE NOTES
after setting up the build environment, it is okay to mv the cmds directory to cmds_build or whatever so that a new cmds directory is used for the next stage (to avoid package name conflicts and retain logs)




