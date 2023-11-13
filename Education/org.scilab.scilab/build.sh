# This file is a configuration file and is not meant to be executed

export PACKAGE="org.scilab.scilab"
export NAME="Scilab"
export VERSION="2024.0.0"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://oos.eu-west-2.outscale.com/scilab-releases/2024.0.0/scilab-${VERSION}.bin.x86_64-linux-gnu.tar.xz"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Open source software for numerical computation"
export DESC2="Scilab is a free and open source software for engineers & scientists, with a long history (first release in 1994) and a growing community (100 000 downloads every months worldwide)."
export DEPENDS=""
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://www.scilab.org/"
export AUTHOR="Dassault Systèmes"

function build() {
    cp -r ${SRC_DIR}/scilab-$VERSION/* $APP_DIR/files
    for i in appdata applications icons locale mime; do
        ln -s ../files/share/$i $APP_DIR/entries/$i
    done
    mv $APP_DIR/files/share/appdata/scilab.appdata.xml $APP_DIR/files/share/appdata/org.scilab.scilab.appdata.xml
    for i in $APP_DIR/files/share/applications/*; do
        sed -i "s#Icon=\(.*\)#Icon=$PACKAGE.\1#g" $i
        sed -i "s#Exec=\(.*\)#Exec=/opt/apps/$PACKAGE/files/bin/\1#g" $i
        mv $i $(dirname "$i")/$PACKAGE.$(basename "$i")
    done
    for d in $(find $APP_DIR/files/share/icons -type d -name "apps"); do
        for i in $d/*; do
            mv $i $(dirname "$i")/$PACKAGE.$(basename "$i")
        done
    done
}
