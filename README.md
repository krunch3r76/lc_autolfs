# lc_autolfs
scripting the lfs package installations

# USAGE
in chroot environment, first set up your environment by sourcing s_f in /sources/lc_autolfs
then cd to /sources
untar the package
rename package directory if desired
enter the package directory
run the environment function (sourced from s_f) mklfscmd
this will move you into a .cmds directory in a separate directory /sources/cmds (made if needed)
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

# VIDEO DEMOS

https://user-images.githubusercontent.com/46289600/155762764-a076924c-3b15-4f5c-a43c-bf56e55dc047.mp4

