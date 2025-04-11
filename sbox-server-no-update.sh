#!/bin/sh
set -e

export WINEPREFIX="$HOME/.wine-sbox"

if [ "$EUID" -eq 0 ]; then
    # Use the root prefix (/wine/prefix)
    export WINEPREFIX="/wine/prefix"
fi

if [ ! -d "$WINEPREFIX" ]; then
    if [ ! -d "/wine/prefix" ]; then
        echo "'/wine/prefix' wasn't found!"
        exit 1
    fi

    echo "Creating a copy of '/wine/prefix'"
    cp -r /wine/prefix "$WINEPREFIX"
    chown -R $USER: "$WINEPREFIX"
fi

wine /wine/steamapps/sbox-server/sbox-server.exe ${SBOX_SERVER_ARGUMENTS} "$@"
