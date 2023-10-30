# This file is a configuration file and is not meant to be executed

export PACKAGE="org.wireshark"
export NAME="Wireshark"
export VERSION="4.0.10"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://2.na.dl.wireshark.org/src/wireshark-${VERSION}.tar.xz"
export REQUIRED_PERMISSIONS=""

export DESC1="Network traffic analyzer"
export DESC2="Wireshark is a network "sniffer" - a tool that captures and analyzes packets off the wire. Wireshark can decode too many protocols to list here."
export DEPENDS="libc6 (>= 2.28), libgcc1 (>= 1:3.0), libglib2.0-0 (>= 2.31.8), libnl-3-200 (>= 3.2.7), libnl-genl-3-200 (>= 3.2.7), libnl-route-3-200 (>= 3.2.7), libpcap0.8 (>= 1.5.1), libqt5core5a (>= 5.11.3), libqt5gui5 (>= 5.11.3), libqt5multimedia5 (>= 5.11.3), libqt5printsupport5 (>= 5.11.3), libqt5widgets5 (>= 5.11.3), libstdc++6 (>= 5.2), zlib1g (>= 1:1.1.4), libc-ares2, libmaxminddb0, libsmi2ldbl, libminizip1, libsnappy1v5, libnghttp2-14, libnl-idiag-3-200, libnl-nf-3-200, libnl-xfrm-3-200, libsbc1, libspandsp2, libkrb5-3, libbrotli1, liblz4-1, libzstd1, liblua5.1-0, libopus0, libspeexdsp1, zenity, libssh-4, deepin-elf-verify (>= 1.1.10-1)"
export BUILD_DEPENDS="libminizip-dev, libpcap-dev, qtmultimedia5-dev, libmaxminddb-dev, libsmi2-dev, libbrotli-dev, liblz4-dev, libsnappy-dev, libnghttp2-dev, liblua5.1-0-dev, libnl-3-dev, libsbc-dev, libspandsp-dev, libopus-dev, libspeexdsp-dev, asciidoctor, libc-ares-dev, libpcre2-dev, qttools5-dev"
export SECTION="utils"
export PROVIDE=""
export HOMEPAGE="https://www.wireshark.org/"

function build() {
    pushd $SRC_DIR

    export DESTDIR=${PKG_DIR}

    pushd wireshark-${VERSION}
    cmake -B build -DCMAKE_INSTALL_PREFIX=/opt/apps/${PACKAGE}/files/ -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF -DCMAKE_PREFIX_PATH=$DESTDIR/opt/apps/${PACKAGE}/files/ &&
        cmake --build build -j $(nproc) &&
        cmake --build build --target install
    popd

    popd

    # modify package name
    for file in $(find ${APP_DIR}/files -name "*org.wireshark.Wireshark*"); do
        if [[ $file =~ .xml ]]; then
            sed -i "s#org.wireshark.Wireshark#org.wireshark#g" $file
        fi
        mv $file ${file/org.wireshark.Wireshark/org.wireshark}
    done

    # modify desktop
    local EP="/opt/apps/${PACKAGE}/files"
    local desktop1=$(find $APP_DIR/files/share/applications -type f -name "*.desktop")
    local desktop2=${desktop1/.desktop/.root.desktop}
    sed -i "s#org.wireshark.Wireshark#org.wireshark#g" $desktop1
    utils.desktop.edit "Exec" "$EP/Run.sh %f" $desktop1
    utils.desktop.edit "TryExec" "$EP/Run.sh" $desktop1
    cp $desktop1 $desktop2
    utils.desktop.edit "Name" "Wireshark (Root)" $desktop2
    utils.desktop.edit "Name[zh_CN]" "Wireshark (Root版)" $desktop2
    utils.desktop.edit "Exec" "$EP/RunAsRoot.sh %f" $desktop2
    utils.desktop.edit "TryExec" "$EP/RunAsRoot.sh" $desktop2

    chmod +x ${ROOT_DIR}/templates/*.sh
    cp ${ROOT_DIR}/templates/*.sh ${APP_DIR}/files/
    cp -R ${ROOT_DIR}/templates/polkit ${APP_DIR}/entries

    # link share
    pushd $APP_DIR/
    for sd in applications icons metainfo mime; do
        ln -s ../files/share/$sd entries/$sd
    done
    popd
}
