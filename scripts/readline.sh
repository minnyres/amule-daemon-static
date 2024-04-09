#!/bin/bash

set -e

cd $SRCDIR/readline-$readline_ver
mkdir -p build-$TARGET
cd build-$TARGET
../configure --host=$TARGET --prefix=$BUILDDIR/readline --enable-static=yes --enable-shared=no --enable-multibyte --enable-largefile --with-curses >> $LOG 2>&1
mkdir -p $BUILDDIR/readline/lib
ln -snf lib $BUILDDIR/readline/lib64
make -j$(nproc) >> $LOG 2>&1
make install >> $LOG 2>&1
make clean >> $LOG 2>&1