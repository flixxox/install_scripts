#!/bin/bash

# CONFIG

SSL_IMPORT_CONFIG_FROM=$1

INSTALL_DIR=${HOME}/local
BUILD_DIR=${INSTALL_DIR}/build

SSL_SOURCE=${BUILD_DIR}/openssl-3.1.4

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
wget -nc https://www.openssl.org/source/openssl-3.1.4.tar.gz
echo "Extracting to ${SSL_SOURCE}" && tar -zxf ${SSL_SOURCE}.tar.gz

cd $SSL_SOURCE
./Configure --prefix="${INSTALL_DIR}" --openssldir="${INSTALL_DIR}/ssl"
make -j 2
make install

# Symlink a few files

if [ ! -d "${INSTALL_DIR}/lib" ]; then
    mkdir -p ${INSTALL_DIR}/lib
fi

ln -s ${INSTALL_DIR}/lib64/* ${INSTALL_DIR}/lib

if [ -d "$1" ]; then
    rm -r ${INSTALL_DIR}/ssl
    ln -s $SSL_IMPORT_CONFIG_FROM ${INSTALL_DIR}
else
    echo "ERROR! Did not find existing config: $SSL_IMPORT_CONFIG_FROM"
fi

# CLEANUP

rm -r $SSL_SOURCE
rm -r ${SSL_SOURCE}.tar.gz
