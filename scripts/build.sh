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
export zlib_ver=1.2.13
export wxwidgets_ver=3.0.5
export pupnp_ver=1.14.13
export cryptopp_ver=860
export cryptopp_autotools_ver=8_6_0
export boost_ver=1.80.0
export boost_ver2=1_80_0
export amule_ver=2.3.3
export libpng_ver=1.6.37

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
zlib_sum=99f0e843f52290e6950cc328820c0f322a4d934a504f66c7caa76bd0cc17ece4bf0546424fc95135de85a2656fed5115abb835fd8d8a390d60ffaf946c8887ad
wxwidgets_sum=ea614d56571ab036983c5d988240d65ae5a94c5c37ee68aa59a904440acc54173cca5def73b5f7b130a40ddc85b5cccc4d8b3d5a36e69c500bbdcfc8b62958cb
pupnp_sum=7d84ad6a05189bb649575567575fd898e69268b22d3c5819a2928f30c1f616b926545467aa9803bec4b532829fdc2db8963dbbe74350938c8e32ff883e983e93
cryptopp_sum=e7773f5e4a7dc7e8e735b1702524bee56ba38e5211544c9c9778bc51ed8dc7b376c17f2e406410043b636312336f26f76dc963f298872f8c13933e88c232fc03
cryptopp_autotools_sum=8e7426b5168c8542d818ac84f3def77fde1997358db566e7a9649b0f8c9dcf14940655ed16945fa70a11d90331e163f8d7cf4a0810575319563cc8da7ff54eb6
boost_sum=829a95b463473d69ff79ea41799c68429bb79d3b2321fbdb71df079af237ab01de9ad7e9612d8783d925730acada010068d2d1aa856c34244ee5c0ece16f208f
libpng_sum=59e8c1059013497ae616a14c3abbe239322d3873c6ded0912403fc62fb260561768230b6ab997e2cccc3b868c09f539fd13635616b9fa0dd6279a3f63ec7e074
amule_sum=a5a80c5ddd1e107d92070c1d8e232c2762c4c54791abc067c739eef7c690062ed164dd7733808f80c762719261162aeb3d602308964dda2670a0bb059d87b74e
amuledlp_sum=8bb0f1ab99edf9ef99b0d8d3038e2bf795922bbda9508b1d44c1d4a8f4deae760ef002efc39342718c4374d2d6221420c56b7cd5a4fd3fc3c99c4965f5037bce
libantileech_sum=75d0746d24aae1bc11dbbd16979bc63b5707932b9e461dcb65a4eff16640bbfbf72a2c7960bc8b08f07f8fe79dede318d512a00469244760e5deff2e06f86772

# ----- Development Directories ----- #
export CURDIR="$PWD"
export SRCDIR="$CURDIR/sources"
export BUILDDIR="$CURDIR/build-$ARCH"
export PCHDIR="$CURDIR/patches"

mkdir -p ${SRCDIR}
mkdir -p ${BUILDDIR}

# ----- Log File ---- #
export LOG="$CURDIR/log.txt"

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

# ----- Publish ----- #
printf -- "${BLUEC}..${NORMALC} Packaging amule...\n"
cd $BUILDDIR
filename=amule-${amule_ver}-linux-${ARCH}.tar.xz
XZ_OPT=-9 tar -cJf $filename amule
mv $filename ${CURDIR}