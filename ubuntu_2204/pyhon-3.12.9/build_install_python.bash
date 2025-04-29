#!/bin/bash

# This script installs python-3.12.9 into $HOME/local.
# If DO_BACKUP=true, a previous $HOME/local is saved.

# Sideeffects of the script are:
# - Upgrading pip
# - Adding lines to the bashrc which set the PATH and PYTHONPATH

# ============ CONFIG

DO_BACKUP=false

# ============ SCRIPT

UBUNTU_VERSION=$(lsb_release -r | cut -d ':' -f 2 | xargs | sed 's/\.//g')
SCRIPT_ROOT=$(dirname $(dirname $0))
SCRIPT_DIR=${SCRIPT_ROOT}/ubuntu_${UBUNTU_VERSION}

INSTALL_DIR=${HOME}/local
BUILD_DIR=${INSTALL_DIR}/build
BACKUP_DIR=${INSTALL_DIR}-backup
PYTHON_SOURCE=${BUILD_DIR}/Python-3.12.9

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

# CREATE DIRECTORIES

if [ ! -d "$INSTALL_DIR" ]; then
    mkdir -p $INSTALL_DIR
fi

if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p $BUILD_DIR
fi

# INSTALL PYTHON

PYTHON_INSTALL_POSTFIX=""

cd $BUILD_DIR
wget -nc https://www.python.org/ftp/python/3.12.9/Python-3.12.9.tgz
echo "Extracting to ${PYTHON_SOURCE}" && tar -zxf ${PYTHON_SOURCE}.tgz

MY_LDFLAGS="-L ${INSTALL_DIR}/lib -Wl,-rpath=${INSTALL_DIR}/lib"
MY_CPPFLAGS="-I ${INSTALL_DIR}/include"

cd ${PYTHON_SOURCE}
LDFLAGS="${MY_LDFLAGS}" \
    CPPFLAGS="${MY_CPPFLAGS}" \
    ./configure --enable-optimizations --with-readline --prefix=${INSTALL_DIR}${PYTHON_INSTALL_POSTFIX}
make -j 2
make install

# CLEANUP

rm -r ${BUILD_DIR}

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
