# ============ CONFIG

DO_BACKUP=false
LOCAL_SQLITE_INSTALL=false

LOCAL_SSL_INSTALL=false
SSL_IMPORT_CONFIG_FROM=/usr/lib/ssl

# ============ SCRIPT

UBUNTU_VERSION=$(lsb_release -r | cut -d ':' -f 2 | xargs | sed 's/\.//g')
SCRIPT_ROOT=$(dirname $(dirname $0))
SCRIPT_DIR=${SCRIPT_ROOT}/ubuntu_${UBUNTU_VERSION}
INSTALL_DIR=${HOME}/lib
PYTHON_SOURCE=Python-3.11.6
PYTHON_BUILD=Python-3.11.6-build
PYTHON_BACKUP=Python-3.11.6-build-backup

echo Ubuntu version: ${UBUNTU_VERSION}
echo Script root: ${SCRIPT_ROOT}
echo Script dir: ${SCRIPT_DIR}
echo Install dir: ${INSTALL_DIR}

cd $INSTALL_DIR

# === Backup Python

if [[ $DO_BACKUP == true ]]; then
    if [ -d "$PYTHON_BUILD" ]; then
        echo "Found already existing $PYTHON_BUILD directory!"
        for i in $(seq 1 20); do
            if [ ! -d "$PYTHON_BACKUP$i" ]; then
                echo "Saving backup to $PYTHON_BACKUP$i"
                mv $PYTHON_BUILD $PYTHON_BACKUP$i
                break
            fi
        done
    fi
fi

# === Install Dependencies

if [[ $LOCAL_SQLITE_INSTALL == true ]]; then
    echo " ========== Installing local sqlite!"
    SQLITE_BUILD=${INSTALL_DIR}/sqlite-3440200-build
    if [ ! -d "$SQLITE_BUILD" ]; then
        echo "Did not find sqlite build. Installing sqlite locally in $SQLITE_BUILD!"
        bash ${SCRIPT_DIR}/build_install_sqlite-3440200.bash
    fi
fi

if [[ $LOCAL_SSL_INSTALL == true ]]; then
    echo " ========== Installing local openssl!"
    SSL_BUILD=${INSTALL_DIR}/openssl-3.1.4-build
    if [ ! -d "$SSL_BUILD" ]; then
        echo "Did not find openssl build. Installing openssl locally in $SSL_BUILD!"
        bash ${SCRIPT_DIR}/build_install_openssl-3.1.4.bash $SSL_IMPORT_CONFIG_FROM
    fi
fi

# === Install Python

# cd ../Python-3.6.2
# LD_RUN_PATH=${INSTALL_BASE_PATH}/lib configure
# LDFLAGS="-L ${INSTALL_BASE_PATH}/lib"
# CPPFLAGS="-I ${INSTALL_BASE_PATH}/include"
# LD_RUN_PATH=${INSTALL_BASE_PATH}/lib make
# ./configure --prefix=${INSTALL_BASE_PATH}
# make
# make install

# cd ~
# LINE_TO_ADD="export PATH=${INSTALL_BASE_PATH}/bin:\$PATH"
# if grep -q -v "${LINE_TO_ADD}" $HOME/.bash_profile; then echo "${LINE_TO_ADD}" >> $HOME/.bash_profile; fi
# source $HOME/.bash_profile