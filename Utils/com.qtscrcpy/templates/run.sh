#!/bin/bash

export QTSCRCPY_CONFIG_PATH="$XDG_CONFIG_HOME/qtscrcpy"
if [[ ! -d "$QTSCRCPY_CONFIG_PATH" ]]; then
    mkdir -p "$QTSCRCPY_CONFIG_PATH"
fi

if [[ ! -f "$QTSCRCPY_CONFIG_PATH/config.ini" ]]; then
    cp "/opt/apps/com.qtscrcpy/files/config.ini" "$QTSCRCPY_CONFIG_PATH/config.ini"
fi

exec /opt/apps/com.qtscrcpy/files/QtScrcpy "$@"
