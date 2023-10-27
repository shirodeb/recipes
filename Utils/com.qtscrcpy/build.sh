# This file is a configuration file and is not meant to be executed

export PACKAGE="com.qtscrcpy"
export NAME="QtScrcpy"
export VERSION="2.1.2"
export ARCH=$(utils.misc.get_current_arch)
export URL=""
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="A Perfect Tool For Android Phone Show Screen On PC"
export DESC2=""
export DEPENDS=""
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/barry-ran/QtScrcpy"
export AUTHOR="barry-ran"

export INGREDIENTS=("cmake-3.27.4-$ARCH" "qt5-5.15.10-$ARCH")

function prepare() {
    if [[ "$1" != "download" && "$1" != "make" ]]; then
        return 0
    fi
    local giturl="https://github.com/barry-ran/QtScrcpy"
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
    # Remove hardcoded qputenv
    sed -i "/^\s*qputenv/ d" QtScrcpy/main.cpp
    cmake -B build -DCMAKE_BUILD_TYPE=Release . || exit -1
    cmake --build build -j$(nproc) || exit -1
    cp output/${ARCH/amd/x}/Release/* $APP_DIR/files/
    cp config/config.ini $APP_DIR/files/
    cp -R $ROOT_DIR/templates/entries/* $APP_DIR/entries/
    cp $ROOT_DIR/templates/run.sh $APP_DIR/files/
    chmod +x $APP_DIR/files/run.sh
    popd
    return 0
}
