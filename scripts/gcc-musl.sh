#!/bin/bash

set -e

help_msg="Usage: ./scripts/gcc-musl.sh -arch=[amd64|armv7|aarch64|mips]"

workdir=$PWD/toolchain

if [ $# == 1 ]; then
    if [ $1 == "-arch=amd64" ]; then
        TARGET=x86_64-linux-musl        
    elif [ $1 == "-arch=aarch64" ]; then
        TARGET=aarch64-linux-musl
    elif [ $1 == "-arch=armv7" ]; then
        TARGET=armv7-linux-musleabihf
    elif [ $1 == "-arch=mips" ]; then
        TARGET=mipsel-linux-muslsf
    else
        echo $help_msg
        exit -1
    fi
else
    echo $help_msg
    exit -1
fi

install_dir=$workdir/gcc-$TARGET 
mkdir -p $install_dir
cd $workdir

if [ ! -d "$workdir/musl-cross-make" ]; then
    git clone https://github.com/richfelker/musl-cross-make.git
fi

cd musl-cross-make
cp config.mak.dist config.mak

GCC_VER=11.2.0
BINUTILS_VER=2.33.1
MUSL_VER=1.2.5

echo "TARGET = $TARGET" >> config.mak
echo "GCC_VER = $GCC_VER" >> config.mak
echo "BINUTILS_VER = $BINUTILS_VER" >> config.mak
echo "MUSL_VER = $MUSL_VER" >> config.mak
echo "COMMON_CONFIG += CFLAGS=\"-g0 -O2\" CXXFLAGS=\"-g0 -O2\" LDFLAGS=\"-s\"" >> config.mak 
echo "GCC_CONFIG += --enable-default-pie" >> config.mak 

make
make install
mv output/* $install_dir