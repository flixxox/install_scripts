
# CONFIG

SSL_IMPORT_CONFIG_FROM=$1

INSTALL_DIR=${HOME}/lib
SSL_SOURCE=${INSTALL_DIR}/openssl-3.1.4
SSL_BUILD=${INSTALL_DIR}/openssl-3.1.4-build

echo "SSL source dir ${SSL_SOURCE}"
echo "SSL build dir ${SSL_BUILD}"

# CLEAN PREVIOUS INSTALL

rm -r $SSL_SOURCE | true
rm -r $SSL_BUILD | true
mkdir -p $SSL_BUILD

# INSTALL

cd $INSTALL_DIR
wget -nc https://www.openssl.org/source/openssl-3.1.4.tar.gz
tar -zxvf ${SSL_SOURCE}.tar.gz

cd $SSL_SOURCE
./Configure --prefix="${SSL_BUILD}" --openssldir="${SSL_BUILD}/ssl"
make
make install

ln -s ${SSL_BUILD}/lib64 ${SSL_BUILD}/lib

if [ -d "$1" ]; then
    ln -s $SSL_IMPORT_CONFIG_FROM ${SSL_BUILD}/ssl
else
    echo "ERROR! Did not find existing config: $SSL_IMPORT_CONFIG_FROM"
fi

# CLEANUP

rm -r $SSL_SOURCE
rm -r ${SSL_SOURCE}.tar.gz
