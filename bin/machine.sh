#!/bin/sh
# machine.sh
# manage the set of hardware-specific machine profiles
# in /etc/machines.d

set -e
#set -x

BASE="/etc/machines.d"    
SUFFIX="tar.bz2"

id=$(/bin/lspci -n | md5sum | awk '{print $1}')

maybe_unpack () {
    local tbz=$BASE/$1.$SUFFIX
    if [ ! -d $BASE/$1 ] && [ -f $tbz ]; then
        # unpack the compressed profile, if needed
        tar -C $BASE -xf $tbz
    fi
}

dir="$BASE/$id"


case $1 in
id)
    echo $id
    ;;
dir*)
    maybe_unpack $id
    if [ ! -d $dir ]; then
        maybe_unpack default
        mkdir -p $dir
        cp -a $BASE/default/* $dir
    fi
    echo $dir
    ;;
env)
    echo $dir/env
    ;;
boot)
    $dir/boot
    ;;
cleanup)
    # make sure each directory is packed up
    # and delete the ones that aren't active
    for p in $(find $BASE -type d -mindepth 1 -maxdepth 1); do
        n=$(basename $p)
        tar -C $BASE -cjf $BASE/$n.$SUFFIX $n
        if [ $n != $id ] && [ $n != "default" ]; then
            rm -rf $p
        fi
    done
    ;;
*)
    echo "$0 ( id | dir | env | boot | cleanup)" >&2
    ;;
esac

