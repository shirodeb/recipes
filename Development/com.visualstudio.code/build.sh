# This file is a configuration file and is not meant to be executed

export PACKAGE="com.visualstudio.code"
export NAME="Visual Studio Code"
export VERSION="1.85"
export ARCH=$(utils.misc.get_current_arch)
export URL="visual-studio-code_${VERSION}_${ARCH}.deb::https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-${ARCH/amd/x}"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

function prepare() {
    if [[ "$ARCH" == "arm64" ]]; then
        export PACKAGE="$PACKAGE.uos"
    fi
}

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
    cp -R $DEB_SRC_DIR/usr/share/code/* $APP_DIR/files/
    cp -R $DEB_SRC_DIR/usr/share/{appdata,mime,bash-completion,pixmaps,zsh} $APP_DIR/entries
    local EXEC_PATH="code"

    # Collect .desktop
    log.debug "Collect .desktop files..."
    utils.desktop.collect "$DEB_SRC_DIR/usr/share/applications"
    # Modify .desktop
    for desktop_file in $(find $APP_DIR/entries/applications -name "*.desktop"); do
        utils.desktop.edit "Exec" "/opt/apps/$PACKAGE/files/${EXEC_PATH} %F" $desktop_file
        utils.desktop.edit "TryExec" "/opt/apps/$PACKAGE/files/${EXEC_PATH}" $desktop_file
    done

    # Collect icons
    log.debug "Collect icons..."
    utils.icon.collect $DEB_SRC_DIR/usr/share/pixmaps

    # Fix chrome-sandbox on kernel 4.19
    utils.misc.chrome_sandbox_treat

    # Get details from original debian/control
    log.debug "Reading existing control file..."
    utils.misc.read_control_from "$DEB_SRC_DIR/DEBIAN/control"

    # Write postinst for vscode
    cat <<EOF >>${PKG_DIR}/debian/postinst
#!/bin/bash

# Check desktop conflict
if [ ! -f "/usr/share/applications/code.desktop" ];then
  echo "Passed"
  else
  rm -f usr/share/applications/code.desktop
fi

ln -s /opt/apps/$PACKAGE/files/bin/code /usr/bin/code
EOF

    cat <<EOF >${PKG_DIR}/debian/postrm
#!/bin/bash
rm -f /usr/bin/code
EOF
    chmod +x ${PKG_DIR}/debian/post{inst,rm}

    # Move and modify appdata/code.appdata.xml
    pushd $APP_DIR/entries/appdata/
    mv code.appdata.xml $PACKAGE.appdata.xml
    sed -i "s/code\.desktop/$PACKAGE.desktop/g" $PACKAGE.appdata.xml
    popd
}
