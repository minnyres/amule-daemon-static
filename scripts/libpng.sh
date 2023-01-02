#!/bin/bash

set -e

cd $SRCDIR/libpng-$libpng_ver
mkdir -p build-$TARGET
cd build-$TARGET
../configure CPPFLAGS="-I$BUILDDIR/zlib/include" LDFLAGS="-L$BUILDDIR/zlib/lib" \
    --host=$TARGET --prefix=$BUILDDIR/libpng --with-zlib-prefix=$BUILDDIR/zlib --enable-shared=no >> $LOG 2>&1
mkdir -p $BUILDDIR/libpng/lib
ln -snf lib $BUILDDIR/libpng/lib64
make >> $LOG 2>&1
make install >> $LOG 2>&1
sed -i 's/libs="-lpng16"/libs="-lpng16 -lz"/g' $BUILDDIR/libpng/bin/libpng-config
make clean >> $LOG 2>&1
