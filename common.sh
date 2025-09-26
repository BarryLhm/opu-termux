#!/bin/sh ## not executable, just for syntax highlighting

set -eu

[ "${BASH_VERSION-}" ] || \
{
	echo "[错误] 需要 bash"
	echo "提示：脚本已指定 bash 作为运行时，请直接运行脚本而不是用使用其他程序打开"
	exit 1
}

####### definitions here

T_ROOT="/data/data/com.termux/files"
R_DIR="/runtime"

SCRIPT="$(realpath "$0")"
[ "${RUNTIME_DIR-}" ] && DIR="$RUNTIME_DIR" || DIR="${SCRIPT%/*}"
PROG="${0##*/}"
C_ROOT="$DIR/rootfs"

DB_MIRROR="https://mirrors.ustc.edu.cn/ubuntu-ports"
DB_VERSION="plucky"

declare -A T_COLOR=\
(
	[RESET]="\e[0m" [UNDERLINE]="\e[4m" [BLINK]="\e[5m"
	[WHITE]="\e[37m\e[1m" [BLACK]="\e[30m" [GRAY]="\e[30m\e[1m"
	[RED]="\e[31m\e[1m" [YELLOW]="\e[33m\e[1m" [GREEN]="\e[32m\e[1m"
	[BLUE]="\e[34m\e[1m" [CYAN]="\e[36m\e[1m" [MAGENTA]="\e[35m\e[1m"
)

# activate them
for i in "${!T_COLOR[@]}"
do T_COLOR["$i"]="$(echo -ne "${T_COLOR["$i"]}")"
done

msg()
{
	local msg="$1"; shift
	for i in BLUE "$@"
	do	echo -n "${T_COLOR["$i"]}"
	done
	echo "$msg${T_COLOR[RESET]}"
}

error()
{
	msg "[错误] $1" RED
	return "${2-1}"
}

errexit()
{
	error "$@" || exit "$?"
}

createdir()
{
	[ -d "$1" ] || mkdir -- "$1" || error "无法创建目录：'$1'"
}

print_run()
{
	msg "[运行命令] $*" GREEN
	"$@"
}

pkg_add()
{
	print_run apt-get update
	print_run apt-get install -y -- "$@"
}

host_prep()
{
	pkg add "proot" "debootstrap" "termux-x11-nightly" "pulseaudio"
}

bootstrap()
{
	createdir "$C_ROOT"
	print_run debootstrap "$DB_VERSION" "$C_ROOT" "$DB_MIRROR" || \
	  error "安装系统失败"
}

c_run()
{
	msg "[进入容器] 命令行：'$*'" GREEN
	LD_PRELOAD="" \
	  proot -0 -r "$C_ROOT" -w "/root" \
	  -b "/dev" -b "/proc" -b "/sys" \
	  -b "$DIR:$R_DIR" \
	  -b "$T_ROOT/home:/root" \
	  -b "$T_ROOT/usr/tmp:/tmp" \
	  -b "/sdcard" \
	  /bin/env -i TERM="$TERM" HOME="/root" RUNTIME_DIR="$R_DIR" \
	  PATH="/usr/bin:/usr/sbin:$R_DIR/bin:/root/bin" \
	  "$@"
}

####### autoexec here

[ -w "/sdcard" ] || \
{
	msg "[提示] 需要存储权限" CYAN
	print_run termux-setup-storage || \
	  msg "[警告] 存储权限未授予，可能影响使用" YELLOW
}

INITIALIZED=1
