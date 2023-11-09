# This file is a configuration file and is not meant to be executed

export SHIRODEB_VER=1
export PACKAGE="com.siyuan.deepin"
export NAME="思源笔记"
export VERSION="2.10.14"
export ARCH=$(sed -e 's/x86_/amd/;s/aarch/arm/' <<<$(uname -m))
export URL=""
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRE_PERMISSION=""

export DESC1="Fuse blocks, outlines, and bidirectional links to build your eternal digital garden. SiYuan is a local-first personal knowledge management system that supports complete offline use, as well as end-to-end encrypted synchronization."
export DESC2=""
export DEPENDS="libgconf-2-4, libgtk-3-0, libnotify4, libnss3, libxss1, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libuuid1, libgbm1, libxcb-dri3-0, kde-cli-tools | kde-runtime | trash-cli | libglib2.0-bin | gvfs-bin, libsecret-1-0, deepin-elf-verify"
export PROVIDES=""
export SECTION="utils"
export HOMEPAGE="https://b3log.org/siyuan/"

export INGREDIENTS=("nodejs" "go")

function prepare() {
    if [[ "$1" != "download" && "$1" != "make" ]]; then
        return 0
    fi
    local giturl="https://github.com/siyuan-note/siyuan"
    mkdir -p "$ROOT_DIR/src"
    pushd "$ROOT_DIR/src"
    if [[ -d "$PACKAGE-$VERSION/.git" ]]; then
        if [[ $(git -C "$PACKAGE-$VERSION" describe --tags) != "v$VERSION" ]]; then
            log.info "delete old checkout"
            rm -rf "$PACKAGE-$VERSION"
            git clone --depth 1 --recursive --branch "v$VERSION" "$giturl" "$PACKAGE-$VERSION"
        else
            log.info "already checkout the tagged version"
        fi
    else
        git clone --depth 1 --recursive --branch "v$VERSION" "$giturl" "$PACKAGE-$VERSION"
    fi
    popd
}

function build() {
    pushd $SRC_DIR
    pushd kernel
    GO111MODULE=on CGO_ENABLED=1 go build --tags "fts5" -o "../app/kernel-linux/SiYuan-Kernel" -v -ldflags "-s -w -X github.com/siyuan-note/siyuan/kernel/util.Mode=prod"
    popd
    pushd app
    sed -i "/.*target: \"AppImage\"/d; s/tar.gz/dir/" electron-builder-linux.yml
    ELECTRON_MIRROR=https://cnpmjs.org/mirrors/electron/ pnpm --registry https://r.cnpmjs.org/ install electron@25.9.3 -D
    pnpm --registry https://r.cnpmjs.org/ i
    pnpm run build
    pnpm run dist-linux
    if [ "$ARCH" == "arm64" ]; then
        cp -r ./build/linux-arm64-unpacked/* $APP_DIR/files/
    else
        cp -r ./build/linux-unpacked/* $APP_DIR/files/
    fi
    popd
    popd

    cat <<EOF >${PKG_DIR}/debian/postinst
#!/bin/bash

# SUID chrome-sandbox for Electron 5+
chmod 4755 '/opt/apps/${PACKAGE}/files/chrome-sandbox' || true
EOF
    chmod +x ${PKG_DIR}/debian/postinst

    cp -r $ROOT_DIR/templates/entries $APP_DIR
}
