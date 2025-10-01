#!/bin/bash ## not executable, just for syntax highlighting

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
R_DIR=/runtime
D_NULL=/dev/null
X_DISPLAY=:3

SCRIPT="$(realpath $0)"
PROG=${1##*/}

[ ${RUNTIME_DIR-} ] && DIR=$RUNTIME_DIR || DIR=${${"$(realpath $0)"%/*}%/*}
RES=$DIR/res
DATA=$DIR/data
LANG_D=$RES/lang
CONF_D=$DATA/conf.d

### configurable
C_ROOT=$DATA/rootfs
OPU_DIR=$DATA/openutau
O_DATA=/sdcard/OpenUtau
###
#. $CONF_D/default.conf

DB_MIRROR=https://mirrors.ustc.edu.cn/ubuntu-ports
DB_SUITE=plucky
DEFAULT_COLOR=GREEN

declare -A T_COLOR=(
	[RESET]='\e[0m' [UNDERLINE]='\e[4m' [BLINK]='\e[5m'
	[WHITE]='\e[37m\e[1m' [BLACK]='\e[30m' [GRAY]='\e[30m\e[1m'
	[RED]='\e[31m\e[1m' [YELLOW]='\e[33m\e[1m' [GREEN]='\e[32m\e[1m'
	[BLUE]='\e[34m\e[1m' [CYAN]='\e[36m\e[1m' [MAGENTA]='\e[35m\e[1m'
)

# gettext
_C()
{
	local key=$1; shift
	printf $M[$key] $@

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
	msg "[$(_C error)] $1" RED
	return "${2-1}"
}

errexit() # same as error
{
	error "$@" || exit "$?"
}

createdir() #(path[] dirs)
{
	local i
	for i in "$@"
	do	[ -d "$i" ] || mkdir -- "$i" || error "无法创建目录：'$i'，请手动处理"
	done
}

print_run() #(string[] cmdline)
{
	msg "[运行命令] $*" GREEN
	"$@"
}

package() #(operation, [string[] args])
{
	local oper="$1"; shift
	case "$oper" in
	sync) print_run apt-get update;;
	add) print_run apt-get install -y "$@";;
	up) print_run apt-get upgrade -y;;
	esac
}

bootstrap() # no args
{
	msg "正在安装系统..."
	createdir "$C_ROOT"
	print_run debootstrap "$DB_SUITE" "$C_ROOT" "$DB_MIRROR" || \
	  error "安装系统失败"
}

c_run() #(string[] cmdline)
{
	msg "[进入容器] 命令行：'$*'" GREEN
	createdir "$C_ROOT/tmp" "$OPU_DIR" "$O_DATA"
	LD_PRELOAD="" \
	  proot -0 --link2symlink --kill-on-exit -r "$C_ROOT" -w "/root" \
	  -b "/dev" -b "/proc" -b "/sys" -b "$C_ROOT/tmp:/dev/shm" \
	  -b "$D_NULL:/proc/partitions" \
	  -b "$DIR:$R_DIR" \
	  -b "/apex" -b "/system" -b "/linkerconfig/ld.config.txt" \
	  -b "$T_STOR" \
	  -b "$T_ROOT/usr/tmp:/tmp" \
	  -b "/sdcard" \
	  -b "$OPU_DIR:$R_DIR/.openutau" \
	  -b "$O_DATA:/root/.local/share/OpenUtau" \
	  /bin/env -i TERM="$TERM" HOME="/root" RUNTIME_DIR="$R_DIR" \
	  PATH="/usr/bin:/usr/sbin:$R_DIR/bin" LANG="zh_CN.UTF-8" \
	  DISPLAY="$X_DISPLAY" GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=3.2 \
	  PULSE_SERVER="tcp:127.0.0.1:4713" \
	  DOTNET_GCHeapHardLimitPercent=50 \
	  "$@"
}

host_svc() #(service)
{
	case "$1" in
	x11) termux-x11 "$X_DISPLAY";;
	virgl) virgl_test_server_android;;
	pulse)	DISPLAY="$X_DISPLAY" pulseaudio --exit-idle-time=-1 \
		  -n -F "$RES/pulse-config.pa";;
	esac
}

####### autoexec here

## load lang

. 

[ -w /sdcard ] && STOR_ACCESS=1 || STOR_ACCESS=0
[ $STOR_ACCESS = 1 ] || msg "[警告] 存储权限未授予，可能影响使用" YELLOW
