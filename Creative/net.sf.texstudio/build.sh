# This file is a configuration file and is not meant to be executed

export PACKAGE="net.sf.texstudio"
export NAME="TexStudio"
export VERSION="4.6.3"
export ARCH=$(utils.misc.get_current_arch)
export URL="texstudio-$VERSION.tar.gz::https://github.com/texstudio-org/texstudio/archive/refs/tags/$VERSION.tar.gz"
# autostart,notification,trayicon,clipboard,account,bluetooth,camera,audio_record,installed_apps
export REQUIRED_PERMISSIONS=""

export DESC1="Latex Editor"
export DESC2="TeXstudio is a program based on Texmaker, that integrates many tools needed to develop documents with LaTeX, in just one application. Using its editor you can write your documents with the help of interactive spell checking, syntax highlighting, automatically code completion and more..."
export DEPENDS=""
export SECTION="misc"
export PROVIDE=""
export HOMEPAGE="https://texstudio.sourceforge.net/"
export AUTHOR="Benito van der Zander, Jan Sundermeyer, Daniel Braun, Tim Hoffmann"
export RECOMMENDS="texlive-latex-base, texlive-latex-extra, texlive-latex-recommended, texlive-base, latex-beamer, dvipng"

export INGREDIENTS=("cmake-3.27.4-$ARCH" "qt5-5.15.10-$ARCH")

function build() {
    pushd $SRC_DIR/texstudio-$VERSION
    cmake -Wno-dev PREFIX=/opt/apps/$PACKAGE/files -DCMAKE_INSTALL_PREFIX=/opt/apps/$PACKAGE/files -DTEXSTUDIO_ENABLE_MEDIAPLAYER=on -DTEXSTUDIO_ENABLE_TESTS=off -DCMAKE_BUILD_TYPE=Release -DTEXSTUDIO_ENABLE_DEBUG_LOGGER=off . -B ./build
    cmake --build ./build --parallel
    DESTDIR=$PKG_DIR cmake --build ./build -t install
    popd

    ln -s ../files/share/applications $APP_DIR/entries/applications
    ln -s ../files/share/icons $APP_DIR/entries/icons
    ln -s ../files/share/texstudio $APP_DIR/entries/texstudio

    utils.desktop.edit "Exec" "/opt/apps/$PACKAGE/files/bin/texstudio %F" $APP_DIR/entries/applications/texstudio.desktop
    utils.desktop.edit "Icon" "$PACKAGE" $APP_DIR/entries/applications/texstudio.desktop

    mv $APP_DIR/entries/applications/{texstudio,$PACKAGE}.desktop
    cp $APP_DIR/entries/icons/hicolor/scalable/apps/{texstudio,$PACKAGE}.svg
}
