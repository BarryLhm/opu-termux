#!/bin/sh ## not executable, just for syntax highlighting

set -eu

[ "${BASH_VERSION-}" ] || \
{
	echo "[错误] 需要 bash"
	echo "提示：脚本已指定 bash 作为运行时，请直接运行脚本而不是用使用其他程序打开"
	exit 1
}

SCRIPT="$(realpath "$0")"
DIR="${SCRIPT##*/}"
#PROG="${0##*/}"
C_ROOT="$DIR/rootfs"
T_ROOT="/data/data/com.termux/files"

DB_MIRROR="https://mirrors.ustc.edu.cn/ubuntu-ports"
DB_VERSION="plucky"

bootstrap()
{
	debootstrap "$DB_VERSION" "$C_ROOT" "$DB_MIRROR"
}

run()
{
	proot -0 -l -r "$ROOT" -w "/root" \
	  -b "$DIR:/runtime" \
	  -b "$T_ROOT/home:/root" \
	  -b "$T_ROOT/usr/tmp:/tmp" \
	  env -i \
	  PATH="/usr/bin:/usr/sbin:/runtime/bin:/root/bin" \
	  TERM="$TERM" HOME="/root" \
	  /bin/bash -l
}
