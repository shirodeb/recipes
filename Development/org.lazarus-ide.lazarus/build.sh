# This file is a configuration file and is not meant to be executed

export PACKAGE="org.lazarus-ide.lazarus"
export NAME="Lazarus"
export VERSION="2.2.6"
export ARCH=$(utils.misc.get_current_arch)
export URL=(
    "lazarus-project_${VERSION}-0_amd64.deb::https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%20${VERSION}/lazarus-project_${VERSION}-0_amd64.deb/download"
    "fpc-laz_3.2.2-210709_amd64.deb::https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%20${VERSION}/fpc-laz_3.2.2-210709_amd64.deb/download"
    "fpc-src_3.2.2-210709_amd64.deb::https://sourceforge.net/projects/lazarus/files/Lazarus%20Linux%20amd64%20DEB/Lazarus%20${VERSION}/fpc-src_3.2.2-210709_amd64.deb/download"
)
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

function build() {
    local DEB_SRC_DIR="$SRC_DIR/${SRC_NAMES[0]}"
    local DEB_SRC_DIR_FPC_LAZ="$SRC_DIR/${SRC_NAMES[1]}"
    local DEB_SRC_DIR_FPC_SRC="$SRC_DIR/${SRC_NAMES[2]}"

    if [[ $1 == "check" ]]; then
        whereis exa >/dev/null && exa --tree $DEB_SRC_DIR && exit 0
        whereis tree >/dev/null && tree $DEB_SRC_DIR && exit 0
        find $DEB_SRC_DIR
        exit 0
    fi

    # Copy content (*manually specify*)
    log.debug "Copy content..."
    cp -R $DEB_SRC_DIR/usr/share/lazarus/$VERSION/* $APP_DIR/files/

    mkdir $PKG_DIR/usr/
    echo "usr/ /" >>$PKG_DIR/debian/install
    cp -R $DEB_SRC_DIR_FPC_LAZ/usr/* $PKG_DIR/usr/
    cp -R $DEB_SRC_DIR_FPC_SRC/usr/* $PKG_DIR/usr/
    for i in lazarus-ide lazbuild startlazarus; do
        ln -s ../opt/apps/$PACKAGE/files/$i $PKG_DIR/usr/$i
    done

    local EXEC_PATH="startlazarus"

    # Collect .desktop
    utils.desktop.collect "$DEB_SRC_DIR/usr/share/applications"
    # Modify .desktop
    for desktop_file in "${ret[@]}"; do
        utils.desktop.edit "Exec" "\"/opt/apps/$PACKAGE/files/${EXEC_PATH}\" %f" "$desktop_file"
        utils.desktop.edit "TryExec" "\"/opt/apps/$PACKAGE/files/${EXEC_PATH}\"" "$desktop_file"
    done

    # Collect icons
    utils.icon.collect "$DEB_SRC_DIR/usr/share/pixmaps"

    # Fix chrome-sandbox on kernel 4.19
    utils.misc.chrome_sandbox_treat

    # Get details from original debian/control
    log.debug "Reading existing control file..."
    utils.misc.read_control_from "$DEB_SRC_DIR/DEBIAN/control"
    export DEPENDS="libgtk2.0-dev (>=2.6.0)"

    cp $DEB_SRC_DIR_FPC_LAZ/DEBIAN/p* $PKG_DIR/debian/
}
