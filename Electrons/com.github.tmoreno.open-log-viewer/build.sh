# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.tmoreno.open-log-viewer"
export NAME="Open Log Viewer"
export VERSION="1.6.0"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/tmoreno/open-log-viewer/releases/download/1.6.0/open-log-viewer_1.6.0.deb"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="A multi-platform log viewer built with Electron and styled with Material Design"
export DESC2=""
export DEPENDS="libgconf-2-4, libgtk-3-0, libnotify4, libnss3, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libgbm1, libxcb-dri3-0, kde-cli-tools | kde-runtime | trash-cli | libglib2.0-bin | gvfs-bin, deepin-elf-verify"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/tmoreno/open-log-viewer"
export AUTHOR="tmoreno"

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
