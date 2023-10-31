# This file is a configuration file and is not meant to be executed

export PACKAGE="com.calibre-ebook.calibre"
export NAME="Calibre"
export VERSION="6.29.0"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://download.calibre-ebook.com/${VERSION}/calibre-${VERSION}-${ARCH/amd/x86_}.txz"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="calibre is a powerful and easy to use e-book manager."
export DESC2=""
export DEPENDS="com.gitee.congtiankong.additional-base-lib | additional-base-lib, bubblewrap, libopengl0"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://calibre-ebook.com/"
export AUTHOR=""

function build() {
    cp -r $SRC_DIR/calibre-$VERSION-${ARCH/amd/x86_}/* $APP_DIR/files/
    cp -r $ROOT_DIR/templates/entries/* $APP_DIR/entries/
    cp $ROOT_DIR/templates/$ARCH/libfreetype.so.6 $APP_DIR/files/lib
}
