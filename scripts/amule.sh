#!/bin/bash

set -e

mkdir -p $BUILDDIR/amule/share/amule
cp $SRCDIR/curl-ca-bundle.crt $BUILDDIR/amule/share/amule

cd $SRCDIR/aMule-$amule_ver

patch -p1 < $PCHDIR/amule-fix-curl_with_tls.patch
patch -p0 < $PCHDIR/amule-fix-upnp_cross_compile.patch
patch -p0 < $PCHDIR/amule-fix-exception.patch
patch -p1 < $PCHDIR/amule-fix-unzip.patch

./autogen.sh  >> $LOG 2>&1
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include -I$BUILDDIR/readline/include -I$BUILDDIR/ncurses/include -DHAVE_LIBCURL" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib -L$BUILDDIR/readline/lib -L$BUILDDIR/ncurses/lib" \
    CXXFLAGS="-DCURL_STATICLIB" CFLAGS="-DCURL_STATICLIB" \
    PKG_CONFIG_PATH="$BUILDDIR/libgd/lib/pkgconfig" \
    --prefix=$BUILDDIR/amule --host=$TARGET \
    --disable-monolithic \
    --enable-amule-daemon --enable-webserver --enable-amulecmd --disable-amule-gui \
    --enable-cas --disable-wxcas --disable-alc --enable-alcc --enable-fileview \
    --enable-static --disable-debug --enable-optimize --enable-mmap \
    --with-zlib=$BUILDDIR/zlib --with-libcurl=$BUILDDIR/curl \
    --with-wx-prefix=$BUILDDIR/wxwidgets --with-wx-config=$BUILDDIR/wxwidgets/bin/wx-config \
    --with-libpng-prefix=$BUILDDIR/libpng --with-libpng-config=$BUILDDIR/libpng/bin/libpng-config \
    --with-crypto-prefix=$BUILDDIR/cryptopp \
    --enable-static-boost --with-boost=$BUILDDIR/boost \
    --with-libupnp-prefix=$BUILDDIR/libupnp --with-denoise-level=0 --enable-ccache  >> $LOG 2>&1

make GDLIB_LIBS="-lgd -lpng16 -lz" -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1

patch -p1 -R < $PCHDIR/amule-fix-unzip.patch
patch -p0 -R < $PCHDIR/amule-fix-exception.patch
patch -p0 -R < $PCHDIR/amule-fix-upnp_cross_compile.patch
patch -p1 -R < $PCHDIR/amule-fix-curl_with_tls.patch

$TARGET-strip $BUILDDIR/amule/bin/*