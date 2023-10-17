# This file is a configuration file and is not meant to be executed

export PACKAGE="com.freerdp.www.freerdp-nightly"
export NAME="FreeRDP"
export VERSION="3.0.0-beta4"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/FreeRDP/FreeRDP/archive/refs/tags/${VERSION}.zip"
export REQUIRED_PERMISSIONS=""

export DESC1="RDP client for Windows Terminal Services (X11 client)"
export DESC2=" FreeRDP is a libre client/server implementation of the Remote Desktop Protocol (RDP). "
export DEPENDS="zenity, libavutil56, libavcodec58, libavresample4, libpkcs11-helper1, libswscale5, libfuse2, krb5-multidev, libsdl2-ttf-2.0-0"
export SECTION="x11"
export PROVIDE="freerdp"
export HOMEPAGE="http://www.freerdp.com/"

function build() {
    pushd $SRC_DIR

    export DESTDIR=${PKG_DIR}

    # build FreeRDP
    pushd FreeRDP-${VERSION}
    cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/apps/${PACKAGE}/files/ -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF &&
        cmake --build build -j $(nproc) &&
        cmake --build build --target install
    popd

    # copy files
    cp -r ${ROOT_DIR}/templates/entries ${APP_DIR}/
    cp ${ROOT_DIR}/templates/*.sh ${APP_DIR}/files/bin/
    cp ${ROOT_DIR}/templates/post{inst,rm} ${PKG_DIR}/debian/
    chmod +x ${APP_DIR}/files/bin/*.sh
    chmod +x ${PKG_DIR}/debian/post*
}
