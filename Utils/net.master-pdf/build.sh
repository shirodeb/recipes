# This file is a configuration file and is not meant to be executed

# For deb

export SHIRODEB_VER=1
export PACKAGE="net.master-pdf"
export NAME="Master PDF Editor"
export VERSION="5.9.61"
export ARCH=$(sed -e 's/x86_/amd/;s/aarch/arm/' <<<$(uname -m))
export URL="https://code-industry.net/public/master-pdf-editor-${VERSION}-qt5.9.${ARCH/amd/x86_}.deb"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRE_PERMISSION=""

function build() {
    if [[ $1 == "check" ]]; then
        exa --tree ${SRC_DIR}/
        exit 0
    fi

    # Build entries
    mkdir -p $APP_DIR/entries/applications

    # Copy content (manually specify)
    cp -R $SRC_DIR/opt/master-pdf-editor-5/* $APP_DIR/files/
    EXEC_PATH="masterpdfeditor5"

    # Modify .desktop
    desktop_files=$(find ${SRC_DIR} -name "*.desktop")
    if [ ${#desktop_files[@]} -gt 0 ]; then
        DESKTOP_FILE=$APP_DIR/entries/applications/${PACKAGE}.desktop
        cp ${desktop_files[0]} $DESKTOP_FILE # copy only first desktop file
        config_edit "Exec" "/opt/apps/$PACKAGE/files/${EXEC_PATH} %U" $DESKTOP_FILE
        config_edit "TryExec" "/opt/apps/$PACKAGE/files/${EXEC_PATH}" $DESKTOP_FILE
        config_edit "Path" "/opt/apps/$PACKAGE/files/" $DESKTOP_FILE
        config_edit "Icon" "$PACKAGE" $DESKTOP_FILE
        config_edit "Terminal" "false" $DESKTOP_FILE
    else
        echo "No desktop file found"
    fi

    # Create icons
    ICON_DIR=$APP_DIR/entries/icons/hicolor/
    mkdir -p $ICON_DIR
    svg_icons=($(find ${SRC_DIR}/usr/share/icons -name "*.svg"))
    png_icons=($(find ${SRC_DIR}/usr/share/icons -name "*.png"))

    if [ ${#svg_icons[@]} -gt 0 ]; then
        mkdir -p $ICON_DIR/scalable/apps/
        cp $svg_icons $ICON_DIR/scalable/apps/${PACKAGE}.svg
    else
        if [ ${#png_icons[@]} -gt 0 ]; then
            for png_icon in ${png_icons[@]}; do
                sz=$(identify $png_icon | cut -d ' ' -f 3 | cut -d 'x' -f 1)
                mkdir -p $ICON_DIR/${sz}x${sz}/apps
                cp $png_icon $ICON_DIR/${sz}x${sz}/apps/${PACKAGE}.png
            done
        else
            echo "No icon image under ${SRC_DIR}/usr/share/icons."
            find ${SRC_DIR}/usr/share/icons
        fi
    fi

    # patch control
    ORIG_CONTROL_FILE=$SRC_DIR/DEBIAN/control
    CONTROL_FILE=$PKG_DIR/debian/control
    DESC1=$(cat ${ORIG_CONTROL_FILE} | grep -oP "Description: \K(.*)$")
    DESC2=$(cat ${ORIG_CONTROL_FILE} | grep -oP "^ \K(.*)$" | tr '\n' ' ')
    DEPENDS=$(cat ${ORIG_CONTROL_FILE} | grep -oP "^Depends: \K(.*)$")
    HOMEPAGE=$(cat ${ORIG_CONTROL_FILE} | grep -oP "^Homepage: \K(.*)$" | sed "s/\\#/\\\\#/")
    SECTION=$(cat ${ORIG_CONTROL_FILE} | grep -oP "^Section: \K(.*)$")
    PROVIDES=$(cat ${ORIG_CONTROL_FILE} | grep -oP "^Provides: \K(.*)$")

    NOW_DIR=$(readlink -f .)
    cd $PKG_DIR/debian/
    cat ${SCRIPT_ROOT}/template/control.patch | sed "s#{DESC1}#${DESC1}#;s#{DESC2}#${DESC2}#;s#{VERSION}#${VERSION}#;s#{ARCH}#${ARCH}#;s#{DEPENDS}#${DEPENDS}#;s#{SECTION}#${SECTION}#;s#{PROVIDES}#${PROVIDES}#;s#{HOMEPAGE}#${HOMEPAGE}#;s#{PACKAGE}#${PACKAGE}#" |
        patch -p0
    cd $NOW_DIR

    # Check wheather a chrome-sandbox existed
    chrome_sandbox=$(find ${APP_DIR}/files -name "chrome-sandbox")
    if [[ $chrome_sandbox != "" ]]; then
        cat <<EOF >${PKG_DIR}/debian/postinst
#!/bin/bash

# SUID chrome-sandbox for Electron 5+
chmod 4755 '/opt/apps/${PACKAGE}/files/${chrome_sandbox#${APP_DIR}/files/}' || true
EOF
        chmod +x ${PKG_DIR}/debian/postinst
    fi

}
