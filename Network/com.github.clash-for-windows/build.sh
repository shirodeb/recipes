# This file is a configuration file and is not meant to be executed

export PACKAGE="com.github.clash-for-windows"
export NAME="Clash For Windows"
export VERSION=""
export ARCH=$(utils.misc.get_current_arch)
export URL=""
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export GITHUB_REPO="Fndroid/clash_for_windows_pkg"

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
    export VERSION="$(jq -r '.tag_name' <<<$resp)"
    local download_url=$(jq -r '.assets[].browser_download_url | select(. | contains("linux") and contains("'${ARCH/amd/x}'"))' <<<$resp)
    local name=$(basename "$download_url")
    export URL="$name::$download_url"
    log.info "Upstream version is $VERSION"
}

function build() {
    SRC_DIR="$SRC_DIR/${SRC_NAMES[0]}/Clash for Windows-${VERSION}-${ARCH/amd/x}-linux"
    cp -r "$SRC_DIR/"* "$APP_DIR/files"
    cp -r "$ROOT_DIR"/templates/entries/* "$APP_DIR/entries/"
    utils.desktop.edit "Version" "$VERSION" "$APP_DIR/entries/applications/com.github.clash-for-windows.desktop"
    utils.desktop.edit "Exec" "/opt/apps/$PACKAGE/files/cfw" "$APP_DIR/entries/applications/com.github.clash-for-windows.desktop"
    utils.misc.chrome_sandbox_treat
    return 0
}
