#!/bin/bash

set -e

cd $SRCDIR/wxWidgets-$wxwidgets_ver
mkdir -p build-$TARGET
cd build-$TARGET
../configure CPPFLAGS="-I$BUILDDIR/zlib/include" LDFLAGS="-L$BUILDDIR/zlib/lib -fPIC" \
    --host=$TARGET --prefix=$BUILDDIR/wxwidgets --with-zlib=sys  \
    --disable-shared --disable-gui --enable-monolithic --disable-debug_flag --enable-optimise --enable-unicode >> $LOG 2>&1
mkdir -p $BUILDDIR/wxwidgets/lib
ln -snf lib $BUILDDIR/wxwidgets/lib64
make >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1