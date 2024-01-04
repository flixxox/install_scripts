# CONFIG

INSTALL_DIR="$HOME/lib"
SQLITE_SOURCE=${INSTALL_DIR}/sqlite-autoconf-3440200
SQLITE_BUILD=${INSTALL_DIR}/sqlite-3440200-build

# CLEAN PREVIOUS INSTALL

rm -r $SQLITE_SOURCE
rm -r $SQLITE_BUILD
mkdir -p $SQLITE_BUILD

# INSTALL

cd $INSTALL_DIR
wget -nc https://sqlite.org/2023/sqlite-autoconf-3440200.tar.gz
tar -zxvf ${SQLITE_SOURCE}.tar.gz

cd $SQLITE_SOURCE
./configure --prefix=${SQLITE_BUILD}
make
make install

# CLEAN UP

rm -r $SQLITE_SOURCE
rm -r ${SQLITE_SOURCE}.tar.gz
