# This file is a configuration file and is not meant to be executed

export PACKAGE="io.ulauncher"
export NAME="Ulauncher"
export VERSION="5.15.4"
export ARCH="all"
export URL="https://github.com/Ulauncher/Ulauncher/releases/download/${VERSION}/ulauncher_${VERSION}_all.deb"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

function build() {
    local DEB_SRC_DIR="$SRC_DIR/${UNARCHIVED_SRC_DIRS[0]}"
    if [[ $1 == "check" ]]; then
        where exa >/dev/null && exa --tree $DEB_SRC_DIR && exit 0
        where tree >/dev/null && tree $DEB_SRC_DIR && exit 0
        find $DEB_SRC_DIR
        exit 0
    fi

    # Copy content (*manually specify*)
    log.debug "Copy content..."
    cp -R $DEB_SRC_DIR/usr/* $APP_DIR/files/
    local EXEC_PATH="bin/ulauncher"

    # ln entries
    ln -s ../files/share/doc $APP_DIR/entries/docs

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

    # Write postinst and postrm
    cat <<EOF >${PKG_DIR}/debian/postinst
#!/bin/bash
ln -s /opt/apps/$PACKAGE/files/bin/ulauncher /usr/bin/ulauncher
ln -s /opt/apps/$PACKAGE/files/bin/ulauncher-toggle /usr/bin/ulauncher-toggle
ln -s /opt/apps/$PACKAGE/files/share/ulauncher /usr/share/ulauncher
ln -s /opt/apps/$PACKAGE/files/lib/python3/dist-packages/ulauncher  /usr/lib/python3/dist-packages/
EOF
    cat <<EOF >${PKG_DIR}/debian/postrm
#!/bin/bash
rm /usr/bin/ulauncher
rm /usr/bin/ulauncher-toggle
rm /usr/share/ulauncher
rm /usr/lib/python3/dist-packages/ulauncher
EOF

    chmod +x ${PKG_DIR}/debian/postinst
    chmod +x ${PKG_DIR}/debian/postrm
}
