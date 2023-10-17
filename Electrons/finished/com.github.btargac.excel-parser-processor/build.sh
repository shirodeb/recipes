# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.btargac.excel-parser-processor"
export NAME="Excel Parser Processor"
export VERSION="1.3.1"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/btargac/excel-parser-processor/releases/download/v1.3.1/Excel-Parser-Processor-1.3.1.AppImage"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Automate Excel downloads in seconds. Simply does the tedious, repetitive operations for all rows of excel files step by step and reports after the job is done. It can download files from URL(s) in a column of Excel files. If a new filename is provided at column B it will rename the file before saving. It will even create sub folders if column C is filled with a valid folder name."
export DESC2=""
export DEPENDS="libgtk-3-0, libnotify4, libnss3, libxtst6, xdg-utils, libatspi2.0-0, libdrm2, libgbm1, libxcb-dri3-0, kde-cli-tools | kde-runtime | trash-cli | libglib2.0-bin | gvfs-bin, deepin-elf-verify"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/btargac/excel-parser-processor"
export AUTHOR="btargac"

function build() {
    pushd $SRC_DIR/*
    cp -r * ${APP_DIR}/files/
    local chrome_sandboxes=($(find ${APP_DIR}/files -name "chrome[-_]sandbox"))
    local root_dir=$(dirname ${chrome_sandboxes[0]})
    local exe=$(find "$root_dir" -maxdepth 1 -type f -perm /u=x,g=x,o=x -not -name "chrome[-_]*" -not -name "lib*.so*")
    local EXEC_PATH="/opt/apps/$PACKAGE/files/excel-parser-processor --no-sandbox"
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
