# This file is a configuration file and is not meant to be executed

export PACKAGE="com.obs-studio"
export NAME="OBS Studio"
export VERSION="29.0.2"		#此处为git仓库中的tag版本
export ARCH=$(utils.misc.get_current_arch)
export URL=""
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

# debian/control file configure
export DESC1="Free and Open Source Streaming/Recording Software"	#Description
export DESC2=""
export DEPENDS="libasound2, libatk-bridge2.0-0, libatk1.0-0, libatspi2.0-0, libc6 (>= 2.28), libcups2, libcurl4, libdrm2, libegl1, libegl-mesa0, libexpat1, libfontconfig1, libfreetype6, libgbm1, libgcc1, libglib2.0-0, libice6, libjansson4, libluajit-5.1-2, libmbedcrypto3, libmbedtls12, libmbedx509-0, libnspr4, libnss3, libpango-1.0-0, libpangocairo-1.0-0, libpulse0, libsm6, libspeexdsp1, libstdc++6, libswresample3, libswscale5, libudev1, libv4l-0, libwayland-client0, libwayland-egl1, libx11-6, libx11-xcb1, libxcb-composite0, libxcb-randr0, libxcb-render0, libxcb-shape0, libxcb-shm0, libxcb-xfixes0, libxcb-xinerama0, libxcb-xv0, libxcb1, libxcomposite1, libxdamage1, libxext6, libxfixes3, libxkbcommon0, libxrandr2, zlib1g, libcurl3-gnutls, libqt5x11extras5, libpci3, libxcb-sync1, libxcb-shape0, libxcb-present0, libx11-xcb1, libgl1, libgl1-mesa-dri, libgl1-mesa-glx, libxinerama1, libsndio7.0, libva2, libva-drm2, libva-glx2, libva-wayland2, libva-x11-2, libvala-0.42-0 | libvala-0.54-0, libvlc5, libvlccore9, libpulse0, libxcb-xinput0, libcjson1 | libudcp-iam, libopengl0"
export BUILD_DEPENDS="libpci-dev libxcb1-dev libxcb-xinerama0-dev libxcb-xfixes0-dev libxcb-sync-dev libxcb-shm0-dev libxcb-shape0-dev libxcb-render0-dev libxcb-present-dev libx11-xcb-dev libx264-dev libcurl4-openssl-dev libluajit-5.1-dev libxcb-composite0-dev libv4l-dev libvlc-dev libspeexdsp-dev libcjson-dev"
export SECTION="video"
export PROVIDE=""
export HOMEPAGE="https://obsproject.com/"
export AUTHOR="OBS Project"

export INGREDIENTS=("cmake" "qt5-5.15.10")

function prepare() {
    if [[ "$1" != "download" && "$1" != "make" ]]; then
        return 0
    fi
    local giturl="https://github.com/obsproject/obs-studio"	#git仓库地址
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
    # Pre-configure before compiling
    cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_AJA=OFF -DUSE_XDG=OFF -DLINUX_PORTABLE=OFF -DCMAKE_INSTALL_PREFIX=//opt/apps/${PACKAGE}/files/ -DENABLE_BROWSER=OFF -DENABLE_PIPEWIRE=OFF -DBUILD_VST=OFF . || exit -1
    cmake --build build -j$(nproc) || exit -1
    cmake --build build --target install
    cp -R $ROOT_DIR/templates/entries/* $APP_DIR/entries/
    cp $ROOT_DIR/templates/AppRun $APP_DIR/files/
    chmod +x $APP_DIR/files/AppRun
    popd
    return 0
}
