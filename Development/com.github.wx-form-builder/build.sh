# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.wx-form-builder"
export NAME="wxFormBuilder"
export VERSION="3.10.1"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/wxFormBuilder/wxFormBuilder/releases/download/v$VERSION/wxFormBuilder-$VERSION-source-full.tar.gz"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="WYSIWYG GUI Designer and Code Generator for wxWidgets"
export DESC2="wxFormBuilder is a GUI designer for programs which
use wxWidgets. It is a very WYSIWYG designer, because it uses
the actual controls to show the result, not some fake representation.
.
Features include generation of C++, Python, XRC, wxLua, PHP. Also
custom plugins are supported and import of XRC code."
export DEPENDS=""
export BUILD_DEPENDS="make"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/wxFormBuilder/wxFormBuilder"
export AUTHOR="wxFormBuilder"

export INGREDIENTS=("cmake" "wxWidgets" "libboost" "gcc")

function build() {
    pushd $SRC_DIR/wxFormBuilder-$VERSION

    # Fix compile error
    sed "44a #include <cstdint>" src/md5/md5.hh
    if ! grep "<cstdint>" src/md5/md5.hh >/dev/null; then
        sed -i "s/override//g" src/rad/auitabart.h
    fi

    cmake -B ./build $CMAKE_OPTIONS -DCMAKE_INSTALL_PREFIX=/opt/apps/$PACKAGE/files/ -DCMAKE_BUILD_TYPE=Release
    cmake --build ./build/ --parallel
    DESTDIR="$PKG_DIR" cmake --build ./build/ -t install
    popd

    for i in $APP_DIR/files/share/{icons,mime,wxformbuilder}; do
        i=${i##*/}
        ln -s ../files/share/${i} $APP_DIR/entries/$i
    done

    utils.desktop.collect "$APP_DIR/files/share/applications"
    sed -i "s#Exec=wxformbuilder#Exec=/opt/apps/$PACKAGE/files/bin/wxformbuilder#" "$APP_DIR/entries/applications/$PACKAGE.desktop"
    for i in $APP_DIR/entries/icons/hicolor/*/apps/*.png; do
        cp $i ${i/apps\/org.wxformbuilder.wxFormBuilder/apps\/$PACKAGE}
    done

    return 0
}
