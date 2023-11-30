# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.hyperkeys"
export NAME="HyperKeys"
export VERSION="1.3.0"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/xurei/hyperkeys/releases/download/v${VERSION}/HyperKeys-${VERSION}.AppImage"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Keyboard shortcuts on steroids"
export DESC2="Unleash the power of your keyboard by letting you bind ANY action to a shortcut.
It's open-source and fully extendable. You can code you own actions or use one from the community !"
export DEPENDS="libfuse2"
export PROVIDES=""
export SECTION="misc"
export HOMEPAGE="https://hyperkeys.xureilab.com/"
export AUTHOR="Xureilab"

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
