# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.hsbalar.preserver"
export NAME="Preserver"
export VERSION="3.0.0"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/hsbalar/preserver/releases/download/v3.0.0/Preserver-linux-x64.tar.gz"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Preserver is desktop notes organiser built on electron, angular2, pouchDB"
export DESC2=""
export DEPENDS="libgconf-2-4, libgtk-3-0, libnotify4, libnss3, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libgbm1, libxcb-dri3-0, kde-cli-tools | kde-runtime | trash-cli | libglib2.0-bin | gvfs-bin, deepin-elf-verify"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/hsbalar/Preserver"
export AUTHOR="hsbalar"

function build() {
    pushd $SRC_DIR/*
    cp -r * ${APP_DIR}/files/
    local EXEC_PATH="/opt/apps/$PACKAGE/files/Preserver"
    if [[ -z $EXEC_PATH ]]; then
        log.error "No electron executable file name specified."
        exit -1
    fi
    popd

    utils.misc.chrome_sandbox_treat
    utils.icon.collect $ROOT_DIR/templates
    rm -rf $APP_DIR/entries/icons/hicolor/**/apps/icon.png
    if ! utils.desktop.collect $APP_DIR/files; then
        utils.desktop.collect $ROOT_DIR/templates
        utils.desktop.edit "Name" "$NAME" "$APP_DIR/entries/applications/$PACKAGE.desktop"
    fi
    utils.desktop.edit "Exec" "$EXEC_PATH %F" "$APP_DIR/entries/applications/$PACKAGE.desktop"
    utils.desktop.edit "Icon" "$PACKAGE" "$APP_DIR/entries/applications/$PACKAGE.desktop"
    return 0
}
