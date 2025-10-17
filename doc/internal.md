
# Internals

## Files / Directories

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

## 

- Script Library (`res/common.zsh`)

A zsh script library that contains necessary global variables and functions

NO command should be executed during load, except test commands and variable definitions

Use this to include this library:

`. "$(dirname "$(realpath "$0")")/res/common.zsh" "$0"`

- PulseAudio configuration (`res/pulse-config.pa`)

A PulseAudio config file that:

disabled device idle suspension

enabled aaudio sink support

allows transportation through tcp

