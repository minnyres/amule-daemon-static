#!/bin/bash

set -e

cd $SRCDIR/aMule-$amule_ver

patch -p0 < $PCHDIR/amule-fix-upnp_cross_compile.patch
patch -p0 < $PCHDIR/amule-fix-exception.patch
patch -p1 < $PCHDIR/amule-fix-unzip.patch

./autogen.sh  >> $LOG 2>&1
./configure CPPFLAGS="-I$BUILDDIR/zlib/include -I$BUILDDIR/libpng/include" \
    LDFLAGS="-L$BUILDDIR/zlib/lib -L$BUILDDIR/libpng/lib" \
    --prefix=$BUILDDIR/amule --host=$TARGET \
    --disable-monolithic \
    --enable-amule-daemon --enable-webserver --enable-amulecmd --disable-amule-gui \
    --enable-cas --disable-wxcas --disable-alc --enable-alcc --enable-fileview \
    --enable-static --disable-debug --enable-optimize --enable-mmap \
    --with-zlib=$BUILDDIR/zlib \
    --with-wx-prefix=$BUILDDIR/wxwidgets --with-wx-config=$BUILDDIR/wxwidgets/bin/wx-config \
    --with-libpng-prefix=$BUILDDIR/libpng --with-libpng-config=$BUILDDIR/libpng/bin/libpng-config \
    --with-crypto-prefix=$BUILDDIR/cryptopp \
    --enable-static-boost --with-boost=$BUILDDIR/boost \
    --with-libupnp-prefix=$BUILDDIR/libupnp --with-denoise-level=0 --enable-ccache  >> $LOG 2>&1

make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1

patch -p1 -R < $PCHDIR/amule-fix-unzip.patch
patch -p0 -R < $PCHDIR/amule-fix-exception.patch
patch -p0 -R < $PCHDIR/amule-fix-upnp_cross_compile.patch

$TARGET-strip $BUILDDIR/amule/bin/*