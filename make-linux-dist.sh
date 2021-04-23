#!/bin/bash -eu

# this blacklist is used by linuxdeploy
EXCLUDELIST=https://raw.githubusercontent.com/AppImage/pkg2appimage/master/excludelist
SO_BLACKLIST="$(curl -sL $EXCLUDELIST | grep -o '^[^ #]*')"
SO_PROCESSED=""

function fail() {
    echo "$1"
    echo "Please beat the crap out of rkevin until he fixes this issue."
    exit 1
}

function copy_dependencies() {
    if [[ $SO_BLACKLIST =~ $1 ]]; then
        return
    fi
    if [[ $SO_PROCESSED =~ $1 ]]; then
        return
    fi
    [[ ! $1 =~ ^[a-zA-Z0-9+\.-]*$ ]] && fail "The library $1 has weird characters!"

    SO_PROCESSED="$SO_PROCESSED $1"
    sudo cp "$2" "$DESTDIR/$1"
    sudo patchelf --set-rpath '$ORIGIN' "$DESTDIR/$1"
    sudo ldd "$2" | while read -ra line; do
        if [[ ${line[0]} == 'linux-vdso.so.1' ]] || [[ ${line[0]} =~ 'ld-linux-x86-64.so.2' ]]; then
            continue
        fi
        [[ ${line[1]} != '=>' ]] && echo ${line[*]} && fail "ldd's output isn't what this script expected!"
        [[ ! ${line[3]} =~ ^\(0x[0-9a-f]*\)$ ]] && echo ${line[*]} && fail "ldd's output isn't what this script expected!"
        copy_dependencies "${line[0]}" "${line[2]}"
    done
}

if [ $# -lt 2 ]; then
    echo "Usage: $0 BUILD_PATH DIST_PATH [DATA_PATH]"
fi

shopt -s dotglob

if [ $# -eq 3 ] && [ -d $3 ]; then
    echo "Copying game files..."
    sudo cp -ar $3/* $2
fi

echo "Relocating dependencies..."
DESTDIR="$2/lib"
sudo mkdir -p $DESTDIR
copy_dependencies oneshot "$1/bin/oneshot"

echo "Copying standard library..."
sudo cp -ar "$1/bin/lib/ruby" "$2/lib/"
sudo cp -ar "$1/bin/lib/cacert.pem" "$2/lib/"
sudo ln -sf "lib/oneshot" "$2/oneshot"

echo "Done!"
