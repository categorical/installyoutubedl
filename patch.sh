#!/bin/bash
_infof(){ local f=$1;shift;printf "\033[96minfo: \033[0m%s\n" "$(printf "$f" "$@")";}
_errorf(){ local f=$1;shift;printf "\033[91merror: \033[0m%s\n" "$(printf "$f" "$@")";}
#dthis="$(dirname "$(readlink -f "$0")")"
dthis="$(cd "$(dirname "$0")"&&pwd)"

dstaging="$dthis/staging"
dprefix="$(cygpath -u 'd:\opt\youtubedl')"
fstaging="$dstaging/youtube-dl"
factive="$dprefix/$(basename "$fstaging")"
dout="$dstaging/contents"

_unpack(){
    [ ! -d "$dout" ]||(set -x;rm -rf "$dout")
    [ -f "$fstaging" ]||return 1
    7z x "$(cygpath -w "$fstaging")" -aoa -o"$(cygpath -w "$dout")"
}

_f(){
    while IFS= read -r -d $'\0';do
        local _v="$(md5sum "$REPLY"|awk '{print $1}')"
        [ "$_v" = "$1" ]&& { printf '%s' "$REPLY";return 0;}
    done < <(find "$dout" -type f -print0|sort -rz)
}

_patch(){
    time sed -i "85s/%s\/'/%s\/0'/" "$(_f '8f733d6331d405feadfa81c6df3b5223')"
}
_pack(){
    [ -d "$dout" ]||return 1
    7z u "$(cygpath -w "$factive")." "$(cygpath -w "$dout")\*"
    chmod 644 "$factive"
}
_clean(){
    [ ! -d "$dout" ]||(set -x;rm -rf "$dout")
}

_usage(){
	cat<<-EOF
	SYNOPSIS
	    $0 -h
	    $0 --patch
	EOF
}
case $1 in
    --unpack)_unpack;;
    --pack)_pack;;
    --patch)_unpack && _patch && _pack && _clean;;
    *)_usage;;
esac
