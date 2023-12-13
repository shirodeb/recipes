# This file is a configuration file and is not meant to be executed

export PACKAGE="com.cataclysmdda.cataclysmdda"
export NAME="CataclysmDDA"
export VER_CODE="0.G"
export VER_DATE="2023-03-01-0054"
export VERSION="$VER_CODE-$VER_DATE"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://github.com/CleverRaven/Cataclysm-DDA/releases/download/$VER_CODE/cdda-linux-tiles-sounds-x64-$VER_DATE.tar.gz"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Cataclysm - Dark Days Ahead. A turn-based survival game set in a post-apocalyptic world."
export DESC2="Cataclysm: Dark Days Ahead is a turn-based survival game set in a post-apocalyptic world. Struggle to survive in a harsh, persistent, procedurally generated world. Scavenge the remnants of a dead civilization for food, equipment, or, if you are lucky, a vehicle with a full tank of gas to get you the hell out of Dodge. Fight to defeat or escape from a wide variety of powerful monstrosities, from zombies to giant insects to killer robots and things far stranger and deadlier, and against the others like yourself, that want what you have…"
export DEPENDS=" libsdl2-2.0-0, libsdl2-mixer-2.0-0, libsdl2-ttf-2.0-0, libsdl2-image-2.0-0"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://cataclysmdda.org/"
export AUTHOR="CDDA Developers"

function build() {
    # That's weird...
    cp -R $SRC_DIR/cataclysmdda-0.F/* $APP_DIR/files
    utils.icon.collect $APP_DIR/files/data/xdg
    utils.desktop.collect $APP_DIR/files/data/xdg
    utils.desktop.edit "Exec" "bash -c \"/opt/apps/$PACKAGE/files/cataclysm-launcher --userdir \\\$HOME/.local/share/cdda\""
    utils.desktop.edit "Icon" "$PACKAGE"
    utils.desktop.append "Name[zh_CN]" "大灾变：劫后余生" "Desktop Entry"
}
