# This file is a configuration file and is not meant to be executed

export PACKAGE="com.zerotier.one"
export NAME="ZeroTier One"
export VERSION="1.12.2"
export ARCH=$(utils.misc.get_current_arch)
export URL=(
    "https://download.zerotier.com/RELEASES/$VERSION/dist/debian/buster/zerotier-one_${VERSION}_$ARCH.deb"
    "zerotier-gui-master.zip::https://github.com/tralph3/ZeroTier-GUI/archive/refs/heads/master.zip"
)
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

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
    cp -R $DEB_SRC_DIR/{etc,lib,usr,var} $PKG_DIR
    cp $SRC_DIR/ZeroTier-GUI-master/src/zerotier-gui $APP_DIR/files/
    mkdir -p $APP_DIR/entries/icons/hicolor/48x48/apps
    cp $SRC_DIR/ZeroTier-GUI-master/img/zerotier-gui.png $APP_DIR/entries/icons/hicolor/48x48/apps/com.zerotier.one.png
    chmod +x $APP_DIR/files/zerotier-gui
    local EXEC_PATH="zerotier-gui"

    # Collect .desktop
    log.debug "Collect .desktop files..."
    utils.desktop.collect "$SRC_DIR/ZeroTier-GUI-master"
    # Modify .desktop
    for desktop_file in $(find $APP_DIR/entries/applications -name "*.desktop"); do
        utils.desktop.edit "Exec" "/opt/apps/$PACKAGE/files/${EXEC_PATH} %U" $desktop_file
        utils.desktop.edit "TryExec" "/opt/apps/$PACKAGE/files/${EXEC_PATH}" $desktop_file
        utils.desktop.edit "Icon" "$PACKAGE" $desktop_file
    done

    # Get details from original debian/control
    log.debug "Reading existing control file..."
    utils.misc.read_control_from "$DEB_SRC_DIR/DEBIAN/control"
    export DEPENDS="$DEPENDS, python3, python3-tk"

    cp $DEB_SRC_DIR/DEBIAN/{postinst,postrm,prerm,conffiles} $PKG_DIR/debian
    echo "etc/ /" >>$PKG_DIR/debian/install
    echo "lib/ /" >>$PKG_DIR/debian/install
    echo "usr/ /" >>$PKG_DIR/debian/install
    echo "var/ /" >>$PKG_DIR/debian/install
}
