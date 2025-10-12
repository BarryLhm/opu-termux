#!/bin/zsh
## not executable, just for syntax highlighting

PS4='[%D{%6.}] '

set -eu

[ "${ZSH_VERSION-}" ] || \
{
	echo "[错误] 需要 Zsh"
	echo "[Error] Zsh required"
	echo "提示：脚本已指定 Zsh 作为运行时，请直接运行脚本而不是用使用其他程序打开"
	echo "PS: This script has specfied Zsh as its runtime,"
	echo "please execute this script directly as a program."
	exit 1
}

####### definitions here

T_STOR=/data/data/com.termux
T_ROOT=$T_STOR/files
D_NULL=/dev/null
X_DISPLAY=:3

## original $0 to be passed from caller
SCRIPT="$(realpath $1)"
PROG=${1##*/}

COMMON="$(realpath $0)"
DIR=${${COMMON%/*}%/*}
RES=$DIR/res
DATA=$DIR/data
LANG_D=$RES/lang
CONF_D=$DATA/conf.d

### configurable
C_ROOT=$DATA/rootfs
OPU_DIR=$DATA/openutau
HOME_DIR=$DATA/home
O_DATA=/sdcard/OpenUtau
###
#. $CONF_D/default.conf

DB_MIRROR=https://mirrors.ustc.edu.cn/ubuntu-ports
DB_SUITE=plucky

GH_REPO=stakira/OpenUtau
declare -A GH_API=([latest]=https://api.github.com/repos/%s/releases/latest)
GH_REL=https://github.com/%s/releases/download/%s/%s

DEFAULT_COLOR=GREEN

declare -A MESSAGES=() ## fallback
declare -A T_COLOR=(
	[RESET]='\e[0m' [UNDERLINE]='\e[4m' [BLINK]='\e[5m'
	[WHITE]='\e[37m\e[1m' [BLACK]='\e[30m' [GRAY]='\e[30m\e[1m'
	[RED]='\e[31m\e[1m' [YELLOW]='\e[33m\e[1m' [GREEN]='\e[32m\e[1m'
	[BLUE]='\e[34m\e[1m' [CYAN]='\e[36m\e[1m' [MAGENTA]='\e[35m\e[1m'
)

# gettext
M()
{
	local key=$1; shift
	printf ${MESSAGES[$key]-untranslated."$key" %s %s %s %s %s %s} $@
}

load_lang()
{
	export LANG=$1
	LANG_F=$LANG_D/$LANG.lang
	[ -f $LANG_F ] && . $LANG_F || \
	{
		msg "Unknown Language: $LANG"
		load_lang en_US.UTF-8
	}
}

msg() #(string message, [T_COLOR[] colors])
{
	local msg=$1 i; shift
	for i in $DEFAULT_COLOR $@
	do	echo -n $T_COLOR[$i]
	done
	echo $msg$T_COLOR[RESET]
}

error() #(string message, [int retval])
{
	msg "[$(M error)] $1" RED
	return ${2-1}
}

errexit() # same as error
{
	error $@ || exit $?
}

createdir() #(path[] dirs)
{
	local i
	for i in $@
	do	[ -d $i ] || mkdir -- $i || error "$(M mkdir.failed $i)"
	done
}

print_run() #(string[] cmdline)
{
	msg "[$(M runcmd)] $*" GREEN
	$@
}

package() #(operation, [string[] args])
{
	local oper=$1; shift
	case $oper in
	sync) print_run apt-get update;;
	add) print_run apt-get install -y $@;;
	up) print_run apt-get upgrade -y;;
	esac
}

bootstrap() # no args
{
	msg "$(M bootstrapping)"
	createdir $C_ROOT
	print_run debootstrap $DB_SUITE $C_ROOT $DB_MIRROR || \
	  error "$(M bootstrap.failed)"
}

c_run() #(string[] cmdline)
{
	msg "$(M cont.run "$*")" GREEN
	createdir $C_ROOT/tmp $OPU_DIR $HOME_DIR $O_DATA
	local cl=(proot -0 -l -L -p --sysvipc --ashmem-memfd --kill-on-exit	)
	  # unix runtime
	  cl+=(  -r $C_ROOT -w /root -b /dev -b /proc -b /sys			)
	  # enabling file based shmem (/dev/shm doesn't exist on android)
	  #   notice the original /tmp in rootfs in not used in other place
	  cl+=(  -b $C_ROOT/tmp:/dev/shm					)
	  # "permission denied" crash prevention ## fuck android selinux
	  cl+=(  -b $D_NULL:/proc/partitions					)
	  # runtime dir
	  cl+=(  -b $DIR:/runtime						)
	  cl+=(  -b /apex -b /system -b /linkerconfig/ld.config.txt -b /data	)
	  # shared tmp, necessary for x11/pulse/virgl sharing
	  cl+=(  -b $T_ROOT/usr/tmp:/tmp					)
	  cl+=(  -b /sdcard							)
	  # bind openutau to a fixed place
	  cl+=(  -b $OPU_DIR:/runtime/.openutau					)
	  # shared home
	  cl+=(  -b $HOME_DIR:/root						)
	  # openutau data
	  cl+=(  -b $O_DATA:/root/.local/share/OpenUtau				)
	  cl+=(	 /bin/env -i							)
	  cl+=(PATH=/usr/bin:/usr/sbin:/runtime/res/bin				)
	  cl+=(HOME=/root TERM=$TERM LANG=$LANG					)
	  cl+=(DISPLAY=$X_DISPLAY PULSE_SERVER=tcp:127.0.0.1:4713		)
	  # virgl
	  cl+=(GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=3.2		)
	  # dotnet gcheap error fix
	  cl+=(DOTNET_GCHeapHardLimitPercent=50					)
	LD_PRELOAD= $cl $@
}

host_svc() #(service)
{
	case $1 in
	x11) termux-x11 $X_DISPLAY;;
	virgl) virgl_test_server_android;;
	pulse)	DISPLAY=$X_DISPLAY pulseaudio --exit-idle-time=-1 \
		  -n -F $RES/pulse-config.pa;;
	esac
}

####### autoexec here

## fixme
load_lang "${LANG_OVERRIDE-zh_CN.UTF-8}"

[ -w /sdcard ] && STOR_ACCESS=1 || STOR_ACCESS=0
[ $STOR_ACCESS = 1 ] || msg "$(M stor.denied)" YELLOW
