#!/bin/bash

# This script installs python-3.11.6 into $HOME/local.
# It provides options to build and install
# - openssl-3.1.4
# - sqlite-3.44.2
# locally into the same directory.
# The script copies pre-built libraries for 
# - bz2
# - lzma
# into the python dynamic library directory.
# If DO_BACKUP=true, a previous $HOME/local is saved.

# ============ CONFIG

DO_BACKUP=true

# INSTALL CONFIG

LOCAL_SSL_INSTALL=true
SSL_IMPORT_CONFIG_FROM=/usr/lib/ssl

LOCAL_SQLITE_INSTALL=true

# LINK CONFIG

LOCAL_SSL_LINK=true
CUSTOM_LIBRARY_DIR=""
CUSTOM_INCLUDE_DIR=""

# ============ SCRIPT

UBUNTU_VERSION=$(lsb_release -r | cut -d ':' -f 2 | xargs | sed 's/\.//g')
SCRIPT_ROOT=$(dirname $(dirname $0))
SCRIPT_DIR=${SCRIPT_ROOT}/ubuntu_${UBUNTU_VERSION}

INSTALL_DIR=${HOME}/local
BUILD_DIR=${INSTALL_DIR}/build
BACKUP_DIR=${INSTALL_DIR}-backup
PYTHON_SOURCE=${BUILD_DIR}/Python-3.11.6

echo Ubuntu version: ${UBUNTU_VERSION}
echo Script root: ${SCRIPT_ROOT}
echo Script dir: ${SCRIPT_DIR}
echo Install dir: ${INSTALL_DIR}
echo Build dir: ${BUILD_DIR}
echo Backup dir: ${BACKUP_DIR}

# BACKUP

if [[ $DO_BACKUP == true ]]; then
    if [ -d "$INSTALL_DIR" ]; then
        echo "Found already existing $INSTALL_DIR directory!"
        for i in $(seq 1 20); do
            if [ ! -d "$BACKUP_DIR$i" ]; then
                echo "Saving backup to $BACKUP_DIR$i"
                mv $INSTALL_DIR $BACKUP_DIR$i
                break
            fi
        done
    fi
fi

# INSTALL DEPENDENCIES

if [[ $LOCAL_SSL_INSTALL == true ]]; then
    echo " ========== Installing local openssl!"
    bash ${SCRIPT_DIR}/build_install_openssl-3.1.4.bash $SSL_IMPORT_CONFIG_FROM
fi

if [[ $LOCAL_SQLITE_INSTALL == true ]]; then
    echo " ========== Installing local sqlite!"
    bash ${SCRIPT_DIR}/build_install_sqlite-3440200.bash
fi

# CREATE

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR
fi

if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p $BUILD_DIR
fi

# INSTALL PYTHON

PYTHON_INSTALL_POSTFIX=""
if [[ $LOCAL_SSL_LINK == true ]]; then
    PYTHON_INSTALL_POSTFIX="${PYTHON_INSTALL_POSTFIX} --with-openssl=${INSTALL_DIR}"
fi

cd $BUILD_DIR
wget -nc https://www.python.org/ftp/python/3.11.6/Python-3.11.6.tgz
echo "Extracting to ${PYTHON_SOURCE}" && tar -zxf ${PYTHON_SOURCE}.tgz

MY_LDFLAGS="-L ${INSTALL_DIR}/lib -Wl,-rpath=${INSTALL_DIR}/lib"
if [ -d "$CUSTOM_LIBRARY_DIR" ]; then
    MY_LDFLAGS="${MY_LDFLAGS} -L ${CUSTOM_LIBRARY_DIR} -Wl,-rpath=${CUSTOM_LIBRARY_DIR}"
fi

MY_CPPFLAGS="-I ${INSTALL_DIR}/include"
if [ -d "$CUSTOM_INCLUDE_DIR" ]; then
    MY_CPPFLAGS="${MY_CPPFLAGS} -I ${CUSTOM_INCLUDE_DIR}"
fi

cd ${PYTHON_SOURCE}
LDFLAGS="${MY_LDFLAGS}" \
    CPPFLAGS="${MY_CPPFLAGS}" \
    ./configure --enable-optimizations --with-readline --prefix=${INSTALL_DIR}${PYTHON_INSTALL_POSTFIX}
make -j 2
make install

# CLEANUP

rm -r ${BUILD_DIR}

# COPY PREBUILD LIBRARIES

cp ${SCRIPT_ROOT}/python-lib-dynload/python-3.11/_bz2.cpython-311-x86_64-linux-gnu.so \
    ${INSTALL_DIR}/lib/python3.11/lib-dynload/_bz2.cpython-311-x86_64-linux-gnu.so
cp ${SCRIPT_ROOT}/python-lib-dynload/python-3.11/_lzma.cpython-311-x86_64-linux-gnu.so \
    ${INSTALL_DIR}/lib/python3.11/lib-dynload/_lzma.cpython-311-x86_64-linux-gnu.so

# UPGRADE PIP

${INSTALL_DIR}/bin/pip3 install --upgrade pip

# CHECK: all those should work

${INSTALL_DIR}/bin/python3 -c "import ssl; print(ssl.OPENSSL_VERSION)"
${INSTALL_DIR}/bin/python3 -c "import _ctypes"
${INSTALL_DIR}/bin/python3 -c "import _sqlite3"
${INSTALL_DIR}/bin/python3 -c "import bz2"
${INSTALL_DIR}/bin/python3 -c "import lzma"

# SETUP BASHRC

BASHRC_PATH="export PATH=${INSTALL_DIR}/bin:\$PATH"
BASHRC_PYTHONPATH="export PYTHONPATH=${INSTALL_DIR}/bin"

if ! grep -q "${BASHRC_PATH}" "${HOME}/.bashrc"; then
    echo -e "\n${BASHRC_PATH}" >> ${HOME}/.bashrc
fi

if ! grep -q "${BASHRC_PYTHONPATH}" "${HOME}/.bashrc"; then
    echo "${BASHRC_PYTHONPATH}" >> ${HOME}/.bashrc
fi
