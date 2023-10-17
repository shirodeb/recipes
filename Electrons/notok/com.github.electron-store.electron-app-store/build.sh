# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.electron-store.electron-app-store"
export NAME="Electron App Store (Unofficial)"
export VERSION="0.0.4"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/Electron-Store/electron-app-store/releases/download/v0.0.4/Electron-Store-0.0.4.AppImage"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="A Cross-Platform App Store for Electron.js Apps"
export DESC2=""
export DEPENDS="libgconf-2-4, libgtk-3-0, libnotify4, libnss3, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libgbm1, libxcb-dri3-0, kde-cli-tools | kde-runtime | trash-cli | libglib2.0-bin | gvfs-bin, deepin-elf-verify"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/Electron-Store/electron-app-store"
export AUTHOR="Electron-Store"

function build() {
    local natives=($(find ${SRC_DIR}/ -name "snapshot_blob.bin"))
    local root_dir=$(dirname ${natives[0]})
    pushd $root_dir
    cp -r * ${APP_DIR}/files/
    local chrome_sandboxes=($(find ${APP_DIR}/files -name "chrome[-_]sandbox"))
    local natives=($(find ${APP_DIR}/files -name "snapshot_blob.bin"))
    local root_dir=$(dirname ${natives[0]})
    local exe=($(find "$root_dir" -maxdepth 1 -type f -perm /u=x,g=x,o=x -not -name "chrome[-_]*" -not -name "lib*.so*"))
    local EXEC_PATH=""
    if [[ "${#exe[@]}" == 1 ]]; then
        EXEC_PATH=${exe[0]##$PKG_DIR}
    else
        local sel=0
        for exe in "${exe[@]}"; do
            echo $sel $exe
            ((sel++))
        done
        echo "Which one is executable?"
        read sel
        EXEC_PATH=${exe[$sel]##$PKG_DIR}
    fi
    log.info Executable path: $EXEC_PATH
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
