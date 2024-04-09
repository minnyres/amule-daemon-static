#!/bin/bash

set -e

cd $SRCDIR/ncurses
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/ncurses --without-shared --without-cxx-binding --without-debug --disable-stripping --enable-largefile >> $LOG 2>&1
mkdir -p $BUILDDIR/ncurses/lib
ln -snf lib $BUILDDIR/ncurses/lib64
make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1