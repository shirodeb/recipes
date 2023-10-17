# This file is a configuration file and is not meant to be executed

export PACKAGE="org.remmina"
export NAME="Remmina"
export VERSION="1.4.32"
export FREERDP_VERSION="2.11.2"
export ARCH=$(utils.misc.get_current_arch)
export URL=(
    "https://gitlab.com/Remmina/Remmina/-/archive/v${VERSION}/Remmina-v${VERSION}.tar.bz2"
    "https://github.com/FreeRDP/FreeRDP/archive/refs/tags/${FREERDP_VERSION}.zip"
)
export REQUIRED_PERMISSIONS=""

export DESC1="GTK+ Remote Desktop Client"
export DESC2="Remote access screen and file sharing to your desktop. Remmina is a remote desktop client written in GTK+, aiming to be useful for system administrators and travellers, who need to work with lots of remote computers in front of either large monitors or tiny netbooks."
export DEPENDS="libatk1.0-0, libavahi-client3, libavahi-common3, libavahi-ui-gtk3-0, libayatana-appindicator3-1, libc6, libcairo2, libgcrypt20, libgdk-pixbuf2.0-0, libglib2.0-0, libgtk-3-0, libice6, libjson-glib-1.0-0, libpango-1.0-0, libsm6, libsodium23, libsoup2.4-1, libssh-4, libssl1.1, libvte-2.91-0, libx11-6, libxext6, default-dbus-session-bus | dbus-session-bus, libusb-1.0-0, libgcrypt20, libsodium23, libssh-4, libvte-2.91-0, libappindicator3-1, libvncserver1, libvncclient1"
export BUILD_DEPENDS="libusb-1.0-0-dev libgcrypt20-dev libsodium-dev libssh-dev libvte-2.91-dev libappindicator3-dev libvncserver-dev libpulse-dev"
export SECTION="utils"
export PROVIDE=""
export HOMEPAGE="https://remmina.org/"

function build() {
    pushd $SRC_DIR

    export DESTDIR=${PKG_DIR}

    # modify package name
    for file in $(find ./Remmina-v${VERSION} -type f -exec grep -Iq . {} \; -print); do
        sed -i "s/org.remmina.Remmina/${PACKAGE}/g" $file 2>/dev/null
    done

    for file in $(find . -type f -name "org.remmina.Remmina*"); do
        mv $file ${file/org.remmina.Remmina/org.remmina}
    done

    # build FreeRDP
    pushd FreeRDP-${FREERDP_VERSION}
    cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/apps/${PACKAGE}/files/ -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF &&
        cmake --build build -j $(nproc) &&
        cmake --build build --target install
    popd

    echo $DESTDIR

    # build Remmina
    pushd Remmina-v${VERSION}
    cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/apps/${PACKAGE}/files/ -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DCMAKE_PREFIX_PATH=$DESTDIR/opt/apps/${PACKAGE}/files/ &&
        cmake --build build -j $(nproc) &&
        cmake --build build --target install
    popd

    popd

    # remove devel files
    dev_files=$(find $APP_DIR -type d \
        -name "include" \
        -or -name "pkgconfig" \
        -or -name "cmake")
    for dev_file in ${dev_files[@]}; do
        rm -rf $dev_file
    done

    # copy share
    mkdir -p $APP_DIR/entries/
    cp -R $APP_DIR/files/share/* $APP_DIR/entries/

    # modify desktop
    for desktop in $(find $APP_DIR/entries/applications/ -type f -name "*.desktop"); do
        sed -i "s#=remmina-file-wrapper#=/opt/apps/org.remmina/files/bin/remmina-file-wrapper#g" $desktop
        sed -i "s#^Exec=#Exec=env LD_LIBRARY_PATH=/opt/apps/org.remmina/files/lib #g" $desktop
    done
    rm -f $APP_DIR/entries/applications/org.remmina-file.desktop

    rm -rf $APP_DIR/entries/mime
    rm -rf $APP_DIR/entries/metainfo
}
