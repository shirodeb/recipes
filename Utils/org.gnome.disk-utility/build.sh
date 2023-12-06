# This file is a configuration file and is not meant to be executed

export PACKAGE="org.gnome.disk-utility"
export NAME="Disk Utility"
export VERSION="45.1"
export ARCH=$(utils.misc.get_current_arch)
export URL="https://gitlab.gnome.org/GNOME/gnome-disk-utility/-/archive/${VERSION}/gnome-disk-utility-${VERSION}.tar.bz2"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Disk Management Utility for GNOME"
export DESC2="View, modify and configure disks and media"
export DEPENDS="udisks2 (>= 2.7.6), dconf-gsettings-backend | gsettings-backend, libatk1.0-0 (>= 1.12.4), libc6 (>= 2.10), libcairo2 (>= 1.2.4), libcanberra-gtk3-0 (>= 0.25), libdvdread4 (>= 4.1.3), libgdk-pixbuf2.0-0 (>= 2.22.0), libglib2.0-0 (>= 2.43.2), libgtk-3-0 (>= 3.21.5), liblzma5 (>= 5.1.1alpha+20120614), libnotify4 (>= 0.7.0), libpango-1.0-0 (>= 1.18.0), libpangocairo-1.0-0 (>= 1.14.0), libpwquality1 (>= 1.1.0), libsecret-1-0 (>= 0.7), libsystemd0 (>= 209), libudisks2-0 (>= 2.7.6)"
export BUILD_DEPENDS="meson, cmake, libdbus-glib-1-dev, libdssialsacompat-dev, libdvdread-dev, libgtk-3-dev, libcanberra-gtk3-dev, libgirepository1.0-dev, valac, libnotify-dev, libsecret-1-dev, libpwquality-dev, libudisks2-dev, liblzma-dev, libsystemd-dev, xsltproc, docbook-xsl"

export SECTION="utils"
export PROVIDE=""
export HOMEPAGE="https://wiki.gnome.org/Apps/Disks"
export AUTHOR=""

function build() {
    # Build
    pushd ${SRC_DIR}/"gnome-disk-utility-${VERSION}"
    sed -i "s#meson_version: '>= 0.59.0'#meson_version: '>= 0.56.0'#" meson.build
    sed -i "/gnome.post_install/,+4d" meson.build
    meson builddir --prefix /opt/apps/$PACKAGE/files || exit -1
    cd builddir
    ninja || exit -1
    DESTDIR=$PKG_DIR ninja install
    popd

    # Link entries
    rm -rf $APP_DIR/entries
    ln -sf files/share $APP_DIR/entries

    find $APP_DIR/entries/ -type f -name "*DiskUtility*" | while read line; do mv $line $(sed "s/DiskUtility/disk-utility/g" <<<$line); done

    # Edit desktop
    utils.desktop.edit "Exec" "env \"LD_LIBRARY_PATH=/opt/apps/$PACKAGE/files/lib/$(gcc -dumpmachine):\\\\\\\\\\\$LD_LIBRARY_PATH\" \"PATH=/opt/apps/$PACKAGE/files/bin:\\\\\\\\\$PATH\" gnome-disks"
    utils.desktop.edit "Icon" "$PACKAGE"
}
