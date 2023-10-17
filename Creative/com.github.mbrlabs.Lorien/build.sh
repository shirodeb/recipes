# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.mbrlabs.lorien"
export NAME="Lorien"
export VERSION="0.5.0"
export ARCH="amd64"
export URL="https://github.com/mbrlabs/Lorien/releases/download/v${VERSION}/Lorien_${VERSION}_Linux.tar.xz"
export REQUIRED_PERMISSIONS=""

export DESC1="Lorien is an infinite canvas drawing/note-taking app that is focused on performance, small savefiles and simplicity."
export DESC2=""
export DEPENDS=""
export SECTION="utils"
export PROVIDE=""
export HOMEPAGE="https://github.com/mbrlabs/Lorien"

function build() {
    cp -r ${ROOT_DIR}/templates/entries ${APP_DIR}/
    cp ${SRC_DIR}/Lorien_${VERSION}_Linux/* ${APP_DIR}/files/
    chmod +x ${APP_DIR}/files/Lorien.x86_64
}
