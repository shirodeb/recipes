#!/bin/bash
## This is a ugly version of script. Try to use it correctly.
## We should firstly confirm the repo info is the latest

# while true;do
# sudo apt update
# if [ "$?" = "0" ];then
# break
# else
# sleep 10
# echo "aptss is locked. Will try it later in 10 secs"
# fi
# done

###### The check update function is diabled since we does not use UOS in building system. 
### Some function is still ugly but i'm lazy to fix it. 
VERSION_FIREFOX_IN_MOZILLA=`curl -fI 'https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=zh-CN' | grep -o 'firefox-[0-9.]\+[0-9]' | sed 's/.*firefox-//'`
## Here we give the value to version
version=$VERSION_FIREFOX_IN_MOZILLA

export PACKAGE="org.mozilla.firefox-nal "
export NAME="Firefox国际版"
export VERSION="$version"
export ARCH="amd64"
export URL="https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=zh-CN"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

function build(){

### Write desktop
cat << EOFFFFFF > $APP_DIR/entries/applications/org.mozilla.firefox-nal.desktop
[Desktop Entry]
Name=Firefox
Name[zh_CN]=Firefox火狐浏览器
Version=1.0
Exec=/opt/apps/org.mozilla.firefox-nal/files/firefox/firefox %U
Comment=Firefox
Icon=org.mozilla.firefox-nal
Type=Application
Terminal=false
StartupNotify=true
Encoding=UTF-8
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml_xml;application/x-mimearchive;x-scheme-handler/http;x-scheme-handler/https;


EOFFFFFF

### Download package
Download_Name="fflatest.tar.bz2"
Download_Url="https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=zh-CN"
aria2c -c -x 16 -s 16  -d "$APP_DIR/files" "$Download_Url" -o "$Download_Name" --summary-interval=1
tar -xvf "$APP_DIR/files"/"$Download_Name" -C "$APP_DIR/files"
rm "$APP_DIR/files"/"$Download_Name"

mkdir -p $APP_DIR/files/firefox/distribution
### Write distribution info and policies
cat << EOFFFFFF > $APP_DIR/files/firefox/distribution/distribution.ini
[Global]
id=flamescion
version=1.0
about=Mozilla Firefox for Spark Store

[Preferences]
app.distributor="Project Spark"
app.distributor.channel="Spark Store"
mozilla.partner.id="flamescion"
EOFFFFFF

cat << EOFFFFFF > $APP_DIR/files/firefox/distribution/policies.json
{
    "policies":
    {
        "DisableAppUpdate": true
    }
}
EOFFFFFF


cp $APP_DIR/files/firefox/browser/chrome/icons/default/default128.png $APP_DIR/entries/icons/org.mozilla.firefox-nal.png


}







