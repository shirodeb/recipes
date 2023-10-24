# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.cherrytree"
export NAME="cherrytree"
export VERSION="1.0.2"
export SUBVERSION="2"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/giuspen/cherrytree/releases/download/v${VERSION}/cherrytree_${VERSION}-${SUBVERSION}.Debian10_${ARCH}.deb"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

function build() {
    local DEB_SRC_DIR="$SRC_DIR/${SRC_NAMES[0]}"
    if [[ $1 == "check" ]]; then
        where exa >/dev/null && exa --tree $DEB_SRC_DIR && exit 0
        where tree >/dev/null && tree $DEB_SRC_DIR && exit 0
        find $DEB_SRC_DIR
        exit 0
    fi

    # Copy content (*manually specify*)
    log.debug "Copy content..."
    cp -R $DEB_SRC_DIR/usr/bin/* $APP_DIR/files/
    cp -R $DEB_SRC_DIR/usr/share/cherrytree $APP_DIR/entries/
    cp -R $DEB_SRC_DIR/usr/share/doc $APP_DIR/entries/
    cp -R $DEB_SRC_DIR/usr/share/locale $APP_DIR/entries/
    cp -R $DEB_SRC_DIR/usr/share/man $APP_DIR/entries/
    cp -R $DEB_SRC_DIR/usr/share/metainfo $APP_DIR/entries/
    cp -R $DEB_SRC_DIR/usr/share/mime-info $APP_DIR/entries/
    local EXEC_PATH="run.sh"

    # Collect .desktop
    log.debug "Collect .desktop files..."
    utils.desktop.collect "$DEB_SRC_DIR/usr/share/applications"

    # Modify .desktop
    for desktop_file in $(find $APP_DIR/entries/applications -name "*.desktop"); do
        utils.desktop.edit "Exec" "/opt/apps/$PACKAGE/files/${EXEC_PATH} %U" $desktop_file
        utils.desktop.edit "TryExec" "/opt/apps/$PACKAGE/files/${EXEC_PATH}" $desktop_file
    done

    # Collect icons
    log.debug "Collect icons..."
    utils.icon.collect $DEB_SRC_DIR/usr/share/icons

    # Fix chrome-sandbox on kernel 4.19
    utils.misc.chrome_sandbox_treat

    # Get details from original debian/control
    log.debug "Reading existing control file..."
    utils.misc.read_control_from "$DEB_SRC_DIR/DEBIAN/control"

    # Copy template
    cp -r ${ROOT_DIR}/templates/* ${APP_DIR}/files/
    chmod +x ${APP_DIR}/files/run.sh
}
