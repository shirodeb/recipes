# This file is a configuration file and is not meant to be executed

export PACKAGE="com.sayonara-player.sayonara"
export NAME="Sayonara Player"
export VERSION="1.7.0-stable3"
export COMMIT="gc78b9667"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://sayonara-player.com/files/appimage/sayonara-${VERSION}-${COMMIT}.AppImage"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Small and lightweight music player."
export DESC2="Sayonara is as a lightweight and fast library manager and music player."
export DEPENDS="libfuse2"
export PROVIDES=""
export SECTION="utils"
export HOMEPAGE="http://sayonara-player.com"

function test() {
    download
    local downloaded_files="${ret[@]}"
    chmod +x "${download_fn[0]}"
    DESKTOPINTEGRATION=1 APPIMAGE_SILENT_INSTALL=1 APPIMAGELAUNCHER_DISABLE=1 "${download_fn[0]}" --no-sandbox

    if zenity --question --no-wrap --text="App ${NAME} OK?"; then
        exit 0 # success
    else
        exit 1 # not success
    fi
}

function build() {
    APPIMAGE_DIR=${SRC_DIR}/${UNARCHIVED_SRC_DIRS[0]}

    # Copy content
    cp -R $APPIMAGE_DIR $APP_DIR/files/

    # Collect .desktop
    utils.desktop.collect "$APPIMAGE_DIR" "-maxdepth 1"
    # Modify .desktop
    local RUN_FILE="/opt/apps/$PACKAGE/files/${UNARCHIVED_SRC_DIRS[0]}/AppRun"
    for desktop_file in $(find $APP_DIR/entries/applications -name "*.desktop"); do
        utils.desktop.edit "Exec" "env DESKTOPINTEGRATION=1 APPIMAGE_SILENT_INSTALL=1 APPIMAGELAUNCHER_DISABLE=1 $RUN_FILE %U" $desktop_file
        utils.desktop.edit "TryExec" "$RUN_FILE" $desktop_file
        sed -i "/^Categories=.*/d" $desktop_file
    done

    # Collect icons
    utils.icon.collect $APPIMAGE_DIR "-maxdepth 1"

    # Fix chrome-sandbox on kernel 4.19
    utils.misc.chrome_sandbox_treat
}
