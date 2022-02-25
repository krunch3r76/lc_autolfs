# lc_autolfs
scripting the lfs package installations

# INSTALLATION
in $LFS/sources (not in chroot)
```bash
git clone https://github.com/krunch3r76/lc_autolfs
cd lc_autolfs
git checkout v0.0.3
```

# USAGE
in chroot environment, first set up your environment by sourcing s_f in /sources/lc_autolfs
```
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
```

# VIDEO DEMOS


https://user-images.githubusercontent.com/46289600/155764359-e4356bfb-6dfc-46d8-8314-be017f6d7a11.mp4



