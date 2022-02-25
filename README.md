# lc_autolfs
scripting the lfs package installations

one problem i have had when installing lfs packages is keeping track or ensuring i ran every command. i wrote scripts to help with this. with my tools, you can review just the commands run or the commands run and their output. you can review the packages installed and in what order (useful if you think you missed one). package names follow the directory name so you can add pass 1 pass 2 etc to whatever you untar. please see the video demo

additionally, once you have written the commands, you can sit back or leave the terminal and review later, they will run by themselves without intervention after a short timeout.

# REQUIREMENTS
the script binary (/usr/bin/script) from your host should be copied to lfs chroot env and placed in the path
the source tarbells have been downloaded into /sources (e.g. via the wget script)

# INSTALLATION
in $LFS/sources (not in chroot)
```bash
git clone https://github.com/krunch3r76/lc_autolfs
cd lc_autolfs
git checkout v0.0.3
```

# USAGE VIDEO DEMOS

this video demonstrates cmd, scmd, tcmd, and pcmd for build commands, install commands, test commands, and post configuration commands respectively. if there were patch commands, patchcmd1,2,3 would have been used.

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
```
the directory /sources/cmds/<pkg-dir-untarred-to> has been created
this directory contains the files:
- script # lists the commands run and output
- cmds # lists just the commands run

the file /sources/journal has a line added to it that is the same as <pkg-dir-untarred-to>
```
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
(lfs chroot) root:/sources/cmds/sysklogd-1.5.1/.cmds
cat >cmd1
```
see video more added soon

## EXAMPLE (from video)

# USAGE NOTES
after setting up the build environment, it is okay to mv the cmds directory to cmds_build or whatever so that a new cmds directory is used for the next stage (to avoid package name conflicts and retain logs)




