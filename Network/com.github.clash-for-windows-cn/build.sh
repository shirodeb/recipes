# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.clash-for-windows-cn"
export NAME="Clash For Windows(汉化版)"
export VERSION=""
export ARCH=$(utils.misc.get_current_arch)
export URL=""
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

# export GITHUB_REPO="Fndroid/clash_for_windows_pkg"
export GITHUB_REPO="Z-Siqi/Clash-for-Windows_Chinese"

export DESC1="Clash For Windows for Linux"
export DESC2="A Windows/macOS/Linux GUI based on Clash and Electron."
export DEPENDS=""
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://github.com/Fndroid/clash_for_windows_pkg"
export AUTHOR="Fndroid"

function prepare() {
    local github_api_url="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
    local resp="$(curl -s $github_api_url)"
    export VERSION="$(jq -r '.tag_name' <<<$resp | sed "s/.*V\([^_]*\).*/\1/g")"
    local url1="app-${VERSION}.tar.gz::https://github.com/Fndroid/clash_for_windows_pkg/releases/download/${VERSION}/Clash.for.Windows-${VERSION}-${ARCH/amd/x}-linux.tar.gz"
    local url2="app_translation-${VERSION}.7z::https://github.com/Z-Siqi/Clash-for-Windows_Chinese/releases/download/CFW-V${VERSION}_CN/app.7z"
    export URL=("$url1" "$url2")
    log.info "Upstream version is $VERSION"
}

function build() {
    SRC_DIR_APP="$SRC_DIR/Clash for Windows-${VERSION}-${ARCH/amd/x}-linux"
    cp -r "$SRC_DIR_APP/"* "$APP_DIR/files"
    cp "$SRC_DIR/app.asar" "$APP_DIR/files/resources/app.asar"
    cp -r "$ROOT_DIR"/templates/entries/* "$APP_DIR/entries/"
    utils.desktop.edit "Version" "$VERSION" "$APP_DIR/entries/applications/com.github.clash-for-windows-cn.desktop"
    utils.desktop.edit "Exec" "/opt/apps/$PACKAGE/files/cfw" "$APP_DIR/entries/applications/com.github.clash-for-windows-cn.desktop"
    utils.misc.chrome_sandbox_treat
    return 0
}
