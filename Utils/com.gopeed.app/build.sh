# This file is a configuration file and is not meant to be executed

export PACKAGE="com.gopeed.app"
export NAME="Gopeed"
export VERSION="1.5.3"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/GopeedLab/gopeed/releases/download/v$VERSION/Gopeed-v${VERSION}-linux-amd64.deb"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export INGREDIENTS=(glibc gcc)

function build() {
    local DEB_SRC_DIR="$SRC_DIR/${SRC_NAMES[0]}"
    if [[ $1 == "check" ]]; then
        whereis exa >/dev/null && exa --tree $DEB_SRC_DIR && exit 0
        whereis tree >/dev/null && tree $DEB_SRC_DIR && exit 0
        find $DEB_SRC_DIR
        exit 0
    fi

    # Copy content (*manually specify*)
    log.debug "Copy content..."
    cp -R $DEB_SRC_DIR/opt/gopeed/* $APP_DIR/files/
    local EXEC_PATH="gopeed"

    # Collect .desktop
    utils.desktop.collect "$DEB_SRC_DIR/usr/share/applications"
    # Modify .desktop
    for desktop_file in "${ret[@]}"; do
        utils.desktop.edit "Exec" "\"/opt/apps/$PACKAGE/files/${EXEC_PATH}\" %U" "$desktop_file"
        utils.desktop.edit "TryExec" "\"/opt/apps/$PACKAGE/files/${EXEC_PATH}\"" "$desktop_file"
    done

    # Collect icons
    utils.icon.collect "$DEB_SRC_DIR/usr/share/icons"

    # Fix chrome-sandbox on kernel 4.19
    utils.misc.chrome_sandbox_treat

    # Get details from original debian/control
    log.debug "Reading existing control file..."
    utils.misc.read_control_from "$DEB_SRC_DIR/DEBIAN/control"

    utils.desktop.append "StartupWMClass" "gopeed" "Desktop Entry"
}
