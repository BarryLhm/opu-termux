
# Internals

- Files / Directories

+ `res/`: resource directory
  + `common.zsh`: script library, see
  + `pulse-config.pa`: PulseAudio configuration
  + `lang/`: localized strings
    + `<$LANG>.lang`
  + `bin/`: executables used in container
    + `envfix`: environment fixer
+ `data/`: data directory, created on first run
  + `rootfs/`: root of the container
  + `home/`: bound to $HOME dir (/root) in container
  + `openutau/`: OpenUtau program dir, bound to /runtime/.openutau in container
  + `opu.zip`: OpenUtau downloaded using DOWNLOAD
+ `call`: a wrapper to call internal functions
+ `START`: start system
+ `DOWNLOAD`: download and install OpenUtau
+ `WIZARD`: configuration wizard
+ `doc/`: documents
