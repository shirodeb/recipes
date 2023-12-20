# This file is a configuration file and is not meant to be executed

export PACKAGE="app.chatboxai.desktop"
export NAME="Chatbox AI"
export VERSION="1.2.1"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://pub-0f2a372de68244aabdee60c9d82c4c6c.r2.dev/releases/Chatbox-${VERSION}-x86_64.AppImage"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="办公学习的AI好助手"
export DESC2="Chatbox支持多款全球最先进的AI大模型服务，支持Windows、Mac和Linux。AI提升工作效率，深受全世界专业人士的好评"
export DEPENDS="libfuse2"
export PROVIDES=""
export SECTION="misc"
export HOMEPAGE="https://chatboxai.app/"
export AUTHOR=""

function test() {
    download
    local downloaded_files="${ret[@]}"
    chmod +x "${downloaded_files[0]}"
    DESKTOPINTEGRATION=1 APPIMAGE_SILENT_INSTALL=1 APPIMAGELAUNCHER_DISABLE=1 "${downloaded_files[0]}" --no-sandbox ||
        DESKTOPINTEGRATION=1 APPIMAGE_SILENT_INSTALL=1 APPIMAGELAUNCHER_DISABLE=1 "${downloaded_files[0]}"

    if zenity --question --no-wrap --text="App ${NAME} OK?"; then
        exit 0 # success
    else
        exit 1 # not success
    fi
}

function build() {
    APPIMAGE_DIR=${SRC_DIR}/${SRC_NAMES[0]}

    # Copy content
    cp -R "$APPIMAGE_DIR" $APP_DIR/files/
    find "$APP_DIR/files" -type d -exec chmod 755 {} \;

    local RUN_FILE="\"/opt/apps/$PACKAGE/files/${SRC_NAMES[0]}/AppRun\""
    # Collect .desktop
    utils.desktop.collect "$APPIMAGE_DIR" "-maxdepth 1"
    # Modify .desktop
    for desktop_file in "${ret[@]}"; do
        utils.desktop.edit "Exec" "env DESKTOPINTEGRATION=1 APPIMAGE_SILENT_INSTALL=1 APPIMAGELAUNCHER_DISABLE=1 $RUN_FILE %U" "$desktop_file"
        utils.desktop.edit "TryExec" "$RUN_FILE" "$desktop_file"
    done
    unset ret

    # Collect icons
    utils.icon.collect "$APPIMAGE_DIR" "-maxdepth 1"

    # Fix chrome-sandbox on kernel 4.19
    utils.misc.chrome_sandbox_treat
}
