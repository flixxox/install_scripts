#!/bin/bash

# CONFIG

INSTALL_DIR=${HOME}/local
BUILD_DIR=${INSTALL_DIR}/build

SQLITE_SOURCE=${BUILD_DIR}/sqlite-autoconf-3440200

echo Install dir: ${INSTALL_DIR}
echo Build dir: ${BUILD_DIR}

# CREATE

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR
fi

if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p $BUILD_DIR
fi

# INSTALL

cd $BUILD_DIR
wget -nc https://sqlite.org/2023/sqlite-autoconf-3440200.tar.gz
echo "Extracting to ${SQLITE_SOURCE}" && tar -zxf ${SQLITE_SOURCE}.tar.gz

cd $SQLITE_SOURCE
./configure --prefix=${INSTALL_DIR}
make -j 2
make install

# CLEAN UP

rm -r $SQLITE_SOURCE
rm -r ${SQLITE_SOURCE}.tar.gz