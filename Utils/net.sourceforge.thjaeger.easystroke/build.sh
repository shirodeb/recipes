# This file is a configuration file and is not meant to be executed

export PACKAGE="net.sourceforge.thjaeger.easystroke"
export NAME="Easystroke"
export VERSION="0.6.0"
export ARCH=$(utils.misc.get_current_arch)
# export URL="http://packages.deepin.com/deepin/pool/main/e/easystroke/easystroke_${VERSION}.orig.tar.gz"
export URL="easystroke-0.6.0-src.zip::https://github.com/MRWITEK/easystroke/archive/refs/heads/master.zip"
export REQUIRED_PERMISSIONS=""

export DESC1="Gesture-recognition application for X11"
export DESC2="Gestures or strokes are movements that you make with you mouse (or your pen, finger etc.) while holding down a specific mouse button. Easystroke will execute certain actions if it recognizes the stroke."
export DEPENDS="xdg-utils, libboost-serialization1.67.0, libatk1.0-0, libatkmm-1.6-1v5, libc6, libcairo-gobject2, libcairo2, libcairomm-1.0-1v5, libdbus-1-3 , libdbus-glib-1-2 , libgcc1 , libgdk-pixbuf2.0-0 , libglib2.0-0 , libglibmm-2.4-1v5 , libgtk-3-0 , libgtkmm-3.0-1v5 , libpango-1.0-0 , libpangocairo-1.0-0 , libpangomm-1.4-1v5, libsigc++-2.0-0v5, libstdc++6, libx11-6, libxext6, libxfixes3, libxi6, libxtst6"
export SECTION="utils"
export PROVIDE=""
export HOMEPAGE="https://github.com/thjaeger/easystroke/"

function build() {
    pushd $SRC_DIR/easystroke-master

    export PREFIX=/opt/apps/$PACKAGE/files/
    export DESTDIR=$PKG_DIR

    /usr/bin/make -j16 || exit -1
    /usr/bin/make install || exit -1

    popd

    for f in $(find ${APP_DIR}/files/share/ -name "*.svg" -or -name "*.desktop"); do
        mv $f ${f/easystroke\./${PACKAGE}\.}
    done

    df=${APP_DIR}/files/share/applications/${PACKAGE}.desktop
    utils.desktop.edit "TryExec" "/opt/apps/${PACKAGE}/files/bin/easystroke" $df
    utils.desktop.edit "Icon" "${PACKAGE}" $df
    sed -i "s#Exec=easystroke#Exec=/opt/apps/${PACKAGE}/files/bin/easystroke#g" $df

    for i in $(ls $APP_DIR/files/share/); do
        ln -s ../files/share/$i $APP_DIR/entries/$i
    done
}
