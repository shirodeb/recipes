# This file is a configuration file and is not meant to be executed

export PACKAGE="com.xnview.xnviewmp"
export NAME="XnView MP"
export VERSION="1.6.1"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://download.xnview.com/XnViewMP-linux-x64.tgz"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Powerful photo management and viewer"
export DESC2="XnView MP is a versatile and powerful photo viewer, image management, image resizer. XnView is one of the most stable, easy-to-use, and comprehensive photo editors. All common picture and graphics formats are supported (JPEG, TIFF, PNG, GIF, WEBP, PSD, JPEG2000, OpenEXR, camera RAW, HEIC, PDF, DNG, CR2)."
export DEPENDS=""
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://www.xnview.com/en/xnviewmp/"
export AUTHOR="XnSoft"

function build() {
    cp -r $SRC_DIR/*/* $APP_DIR/files
    mkdir -p $APP_DIR/entries
    utils.icon.collect $APP_DIR/files "-maxdepth 1 -name xnview.png"
    utils.desktop.collect $APP_DIR/files
    utils.desktop.edit "Exec" "env QT_PLUGIN_PATH=/usr/lib/x86_64-linux-gnu/qt5/plugins /opt/apps/$PACKAGE/files/xnview.sh %F"
    utils.desktop.edit "TryExec" "/opt/apps/$PACKAGE/files/xnview.sh"
    return 0
}
