#!/bin/bash

set -e

# ----- Colors ----- #
export REDC='\033[1;31m'
export GREENC='\033[1;32m'
export YELLOWC='\033[1;33m'
export BLUEC='\033[1;34m'
export NORMALC='\033[0m'

# ----- Architecture Flags----- #
ARCH=$1

if [ $ARCH == "amd64" ]; then
    TARGET=x86_64-linux-musl 
    address=64
elif [ $ARCH == "armv7" ]; then
    TARGET=armv7-linux-musleabihf
    address=32
elif [ $ARCH == "aarch64" ]; then
    TARGET=aarch64-linux-musl
    address=64
elif [ $ARCH == "mips" ]; then
    TARGET=mipsel-linux-muslsf
    address=32
else
    printf -- 'Usage: ./scripts/build.sh <architecture>\n'
    printf -- 'Supported Architectures: amd64, armv7, aarch64 and mips'
    exit -1
fi
export TARGET
export address
export PATH=$PWD/toolchain/gcc-$TARGET/bin:$PATH

# ----- Package Versions ----- #
export zlib_ver=1.3
export wxwidgets_ver=3.2.3
export pupnp_ver=1.14.18
export cryptopp_ver=880
export cryptopp_autotools_ver=8_8_0
export boost_ver=1.83.0
export boost_ver2=1_83_0
export amule_ver=2.3.3
export libpng_ver=1.6.40
export amule_build=2.3.3.2

# ----- Package URLs ----- #
zlib_url=http://zlib.net/zlib-${zlib_ver}.tar.gz
wxwidgets_url=https://github.com/wxWidgets/wxWidgets/releases/download/v${wxwidgets_ver}/wxWidgets-${wxwidgets_ver}.tar.bz2
pupnp_url=https://github.com/pupnp/pupnp/releases/download/release-${pupnp_ver}/libupnp-${pupnp_ver}.tar.bz2
cryptopp_url=http://cryptopp.com/cryptopp${cryptopp_ver}.zip
cryptopp_autotools_url=https://github.com/noloader/cryptopp-autotools/archive/refs/tags/CRYPTOPP_${cryptopp_autotools_ver}.tar.gz
boost_url=https://boostorg.jfrog.io/artifactory/main/release/${boost_ver}/source/boost_${boost_ver2}.tar.bz2
libpng_url=https://download.sourceforge.net/libpng/libpng-${libpng_ver}.tar.xz
amule_url=http://prdownloads.sourceforge.net/amule/aMule-${amule_ver}.tar.xz
amuledlp_url=https://github.com/persmule/amule-dlp/archive/refs/heads/master.zip
libantileech_url=https://github.com/persmule/amule-dlp.antiLeech/archive/refs/heads/master.zip

# ----- Package Checksums (sha512sum) ----- #
zlib_sum=185795044461cd78a5545250e06f6efdb0556e8d1bfe44e657b509dd6f00ba8892c8eb3febe65f79ee0b192d6af857f0e0055326d33a881449f3833f92e5f8fb
wxwidgets_sum=72e00cea25ab82d5134592f85bedeecb7b9512c00be32f37f6879ca5c437569b3b2b77de61a38e980e5c96baad9b1b0c8ad70773d610afbe9421fa4941d31f99
pupnp_sum=1cbff151e12c8cdfc369d63282afa8cedc3c9498676213e56371bf6dc3d40c5313149da895ba0177541cdb45d928de26248579cbf8d0006adfdcd445a65ef4bb
cryptopp_sum=3fb1c591735f28dbd1329a6de6de9c495388c88bd5c4f077894c41668398ed313f14121a4553e0d4aa71e552ee8c3b744b770711748528ade71043ecc6159c80
cryptopp_autotools_sum=a86b703b596644fe7793b6c65c284847bbcf25d0e3d7198ceaff4ba3ba93ab1ed81acba75c4ae5aa25d1bca6d6e92dbf775bfb1f15130a2892ffb6a693913dc0
boost_sum=d133b521bd754dc35a9bd30d8032bd2fd866026d90af2179e43bfd7bd816841f7f3b84303f52c0e54aebc373f4e4edd601a8f5a5e0c47500e0e852e04198a711
libpng_sum=a2ec37c529bf80f3fee3798191d080d06e14d6a1ffecd3c1a02845cb9693b5e308a1d82598a376101f9312d989d19f1fb6735b225d4b0b9f1b73f9f8a3edb17f
amule_sum=a5a80c5ddd1e107d92070c1d8e232c2762c4c54791abc067c739eef7c690062ed164dd7733808f80c762719261162aeb3d602308964dda2670a0bb059d87b74e
amuledlp_sum=a01401cf73be69c2af59785bbef343bcfd189dd1fa3ce880b63e1c59d80b5cd1475a375a0cf621e5eb9898aa7dd3d41e7835fa484fd23a6070e191c1c5577cfa
libantileech_sum=75d0746d24aae1bc11dbbd16979bc63b5707932b9e461dcb65a4eff16640bbfbf72a2c7960bc8b08f07f8fe79dede318d512a00469244760e5deff2e06f86772

# ----- Development Directories ----- #
export CURDIR="$PWD"
export SRCDIR="$CURDIR/sources"
export BUILDDIR="$CURDIR/build-$ARCH"
export PCHDIR="$CURDIR/patches"

mkdir -p ${SRCDIR}
mkdir -p ${BUILDDIR}

# ----- Log File ---- #
export LOG="$CURDIR/log-$ARCH.txt"

# ----- dpackage(): Download Function ----- #
dpackage() {

  if [ $# == 3 ]; then
    HOLDER=$3
  else
    HOLDER="$(basename $1)" 
  fi

  if [ ! -f "$HOLDER" ]; then
    printf -- "${BLUEC}..${NORMALC} Fetching "$HOLDER"...\n"
    wget -q --show-progress "$1" -O $HOLDER
  else
    printf -- "${YELLOWC}!.${NORMALC} "$HOLDER" already exists, skipping...\n"
  fi

  printf -- "${BLUEC}..${NORMALC} Verifying "$HOLDER"...\n"
  printf -- "$2 $HOLDER" | sha512sum -c || {
    printf -- "${YELLOWC}!.${NORMALC} "$HOLDER" is corrupted, redownloading...\n" &&
    rm "$HOLDER" &&
    wget -q --show-progress "$1" -O $HOLDER;
  }

}

# ----- Download and Extract Sources ----- #
cd ${SRCDIR}
dpackage ${zlib_url} ${zlib_sum}
dpackage ${wxwidgets_url} ${wxwidgets_sum}
dpackage ${pupnp_url} ${pupnp_sum}
dpackage ${boost_url} ${boost_sum}
dpackage ${libpng_url} ${libpng_sum}
dpackage ${cryptopp_url} ${cryptopp_sum}
dpackage ${cryptopp_autotools_url} ${cryptopp_autotools_sum} cryptopp-autotools-CRYPTOPP_${cryptopp_autotools_ver}.tar.gz
dpackage ${amule_url} ${amule_sum}
dpackage ${amuledlp_url} ${amuledlp_sum} amule-dlp-master.zip
dpackage ${libantileech_url} ${libantileech_sum} amule-dlp.antiLeech-master.zip

printf -- "${BLUEC}..${NORMALC} Extracting sources...\n"
tar -xf "$(basename ${zlib_url})"
tar -xf "$(basename ${wxwidgets_url})"
tar -xf "$(basename ${pupnp_url})"
tar -xf "$(basename ${boost_url})"
tar -xf "$(basename ${amule_url})"
tar -xf "$(basename ${libpng_url})"
7z x -aoa amule-dlp-master.zip
7z x -aoa amule-dlp.antiLeech-master.zip
tar -xf cryptopp-autotools-CRYPTOPP_${cryptopp_autotools_ver}.tar.gz
mkdir -p cryptopp${cryptopp_ver}
cd cryptopp${cryptopp_ver} 
7z x -aoa "../$(basename ${cryptopp_url})"
cp ../cryptopp-autotools-CRYPTOPP_${cryptopp_autotools_ver}/* .
mkdir -p m4

# ----- Build 3rd-party libraries and aMule ----- #
cd ${CURDIR}
printf -- "${BLUEC}..${NORMALC} Building zlib...\n"
./scripts/zlib.sh
printf -- "${BLUEC}..${NORMALC} Building libupnp...\n"
./scripts/libupnp.sh
printf -- "${BLUEC}..${NORMALC} Building cryptopp...\n"
./scripts/cryptopp-autotools.sh
printf -- "${BLUEC}..${NORMALC} Building wxwidgets...\n"
./scripts/wxwidgets.sh
printf -- "${BLUEC}..${NORMALC} Building boost...\n"
./scripts/boost.sh
printf -- "${BLUEC}..${NORMALC} Building libpng...\n"
./scripts/libpng.sh
printf -- "${BLUEC}..${NORMALC} Building amule...\n"
./scripts/amule.sh
# printf -- "${BLUEC}..${NORMALC} Building amule-dlp...\n"
# ./scripts/amule-dlp.sh

# ----- Publish ----- #
printf -- "${BLUEC}..${NORMALC} Packaging amule...\n"
cd $BUILDDIR
filename=amule-${amule_build}-linux-${ARCH}.tar.xz
XZ_OPT=-9 tar -cJf $filename amule
mv $filename ${CURDIR}

# printf -- "${BLUEC}..${NORMALC} Packaging amule-dlp...\n"
# cd $BUILDDIR
# filename=amule-dlp-$(printf '%(%Y-%m-%d)T\n' -1)-linux-${ARCH}.tar.xz
# XZ_OPT=-9 tar -cJf $filename amule-dlp
# mv $filename ${CURDIR}