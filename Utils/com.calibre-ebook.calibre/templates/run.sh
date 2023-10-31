EXEC_ROOT="/opt/apps/com.calibre-ebook.calibre/files/"
ABL_ROOT="$EXEC_ROOT/abl"

ABL_LDSO_PATH=`readlink -e /lib64/ld-linux-x86-64.so.2`
ABL_LIBC_PATH=`readlink -e /usr/lib/x86_64-linux-gnu/libc.so.6`

exec bwrap \
--dev-bind / / \
--bind $ABL_ROOT/ld-linux-x86-64.so.2 "$ABL_LDSO_PATH" \
--bind $ABL_ROOT/libc.so.6 "$ABL_LIBC_PATH" \
--bind $ABL_ROOT/ldd /usr/bin/ldd \
--setenv LD_LIBRARY_PATH "$EXEC_ROOT/lib" \
-- $EXEC_ROOT/calibre "$@"

