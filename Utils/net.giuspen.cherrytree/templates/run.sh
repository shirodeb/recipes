#!/bin/bash

BASE_DIR=$(dirname $(readlink -f $0))
if [ ! -f /usr/lib/x86_64-linux-gnu/libgspell-1.so.1 ]; then
    echo "Load libgsped-1-1 for v23"
    export LD_LIBRARY_PATH=${BASE_DIR}/lib
fi

${BASE_DIR}/cherrytree "$@"
