#!/bin/bash

export PACKAGE="org.mozilla.firefox-nal"
export NAME="Firefox国际版"
export VERSION=""
export ARCH="amd64"
export URL="fflatest.tar.bz2::https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=zh-CN"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="No shady privacy policies or back doors for advertisers. Just a lightning fast browser that doesn't sell you out."
export SECTION="web"

function prepare() {
    # Inside this function. We could prepare any meta info that is needed for shirodeb.
    # Example, fetch the version info from upstream instead manually specifying.
    export VERSION=$(curl -sfI 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=zh-CN' | grep -o 'firefox-[0-9.]\+[0-9]' | sed 's/.*firefox-//')
}

function build() {
    cp -r $SRC_DIR/${UNARCHIVED_SRC_DIRS[0]}/* $APP_DIR/files/

    mkdir -p $APP_DIR/entries/applications
    mkdir -p $APP_DIR/entries/icons/
    mkdir -p $APP_DIR/files/firefox/distribution

    cp $ROOT_DIR/templates/org.mozilla.firefox-nal.desktop $APP_DIR/entries/applications/org.mozilla.firefox-nal.desktop
    cp $ROOT_DIR/templates/distribution.ini $APP_DIR/files/firefox/distribution/distribution.ini
    cp $ROOT_DIR/templates/policies.json $APP_DIR/files/firefox/distribution/policies.json
    utils.icon.collect "$APP_DIR/files/firefox/browser/chrome/icons/default/"
    cp $APP_DIR/files/firefox/browser/chrome/icons/default/default128.png $APP_DIR/entries/icons/org.mozilla.firefox-nal.png
}
