#!/usr/bin/env bash

set -e

. scripts/func.sh

if [ ! -d .buildroot ]; then
  echo "Downloading buildroot"
  git clone --single-branch -b 2023.02.x https://github.com/buildroot/buildroot.git .buildroot
fi

# Convert po2mo, Get extractor, LKM, addons and Modules
convertpo2mo "files/board/rr/overlayfs/opt/rr/lang"
getExtractor "files/board/rr/p3/extractor"
getLKMs "files/board/rr/p3/lkms" true
getAddons "files/board/rr/p3/addons" true
getModules "files/board/rr/p3/modules" true

# Remove old files
rm -rf ".buildroot/output/target/opt/rr"
rm -rf ".buildroot/board/rr/overlayfs"
rm -rf ".buildroot/board/rr/p1"
rm -rf ".buildroot/board/rr/p3"

# Copy files
echo "Copying files"
VERSION=$(cat VERSION)
sed 's/^RR_VERSION=.*/RR_VERSION="'${VERSION}'"/' -i files/board/rr/overlayfs/opt/rr/include/consts.sh
echo "${VERSION}" >files/board/rr/p1/RR_VERSION
cp -Ru files/* .buildroot/

cd .buildroot
echo "Generating default config"
make BR2_EXTERNAL=./external -j$(nproc) rr_defconfig
echo "Version: ${VERSION}"
echo "Building... Drink a coffee and wait!"
make BR2_EXTERNAL=./external -j$(nproc)
cd -
