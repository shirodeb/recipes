# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.unciv"
export NAME="Unciv"
export VERSION="4.9.6"
export ARCH="all"
export URL=(
    "https://github.com/yairm210/Unciv/releases/download/$VERSION/Unciv-Linux64.zip"
    "https://github.com/yairm210/Unciv/releases/download/$VERSION/linuxFilesForJar.zip"
    "https://raw.githubusercontent.com/yairm210/Unciv/master/extraImages/Icons/Unciv%20icon%20v6.png"
)
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Open-source Android/Desktop remake of Civ V"
export DESC2="An open source, mod-friendly Android and Desktop remake of Civ V, made with LibGDX"
export DEPENDS="openjdk-11-jre"
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/yairm210/Unciv"
export AUTHOR="yairm210"

function build() {
    cp -r $SRC_DIR/Unciv-Linux64/* $APP_DIR/files/
    cp -r $SRC_DIR/linuxFilesForJar/Unciv.sh $APP_DIR/files/
    rm -rf $APP_DIR/files/jre
    utils.icon.collect "$SRC_DIR/" "-maxdepth 1"
    utils.desktop.collect "$SRC_DIR/linuxFilesForJar" "-maxdepth 1"
    find $APP_DIR/entries/icons/ -name "Unciv*.png" -exec rm {} \;

    chmod +x $APP_DIR/files/Unciv.sh
    rm $APP_DIR/files/Unciv

    utils.desktop.edit "Exec" "/opt/apps/$PACKAGE/files/Unciv.sh"
    utils.desktop.edit "Icon" "$PACKAGE"

    sed -i "s#^java.*.jar\$#JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/bin/java /usr/lib/jvm/java-11-openjdk-amd64/bin/java -jar /opt/apps/$PACKAGE/files/Unciv.jar#g" $APP_DIR/files/Unciv.sh
}
