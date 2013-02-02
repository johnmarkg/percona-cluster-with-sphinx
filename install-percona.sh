#!/bin/bash

DATA_DIR=/home/percona-cluster
PERCONA_URL="http://www.percona.com/redir/downloads/Percona-XtraDB-Cluster/LATEST/source/Percona-XtraDB-Cluster-5.5.29.tar.gz"
SPHINX_URL="http://sphinxsearch.com/files/sphinx-2.0.6-release.tar.gz"
GALERA_URL="https://launchpad.net/galera/2.x/23.2.2/+download/galera-23.2.2-amd64.deb"

PERCONA_DEST=/usr/local/percona-cluster-5.5.29
PERCONA_BUILD_FILE="BUILD/compile-amd64-wsrep"
PERCONA_BASE_DIR=/home/percona-cluster/
PERCONA_CNF=/etc/mysql/my-cluster.cnf

MYSQL_USER_TABLES=/home/mysql/data/mysql/

PERCONA_FILE=${PERCONA_URL##http*/}
PERCONA_SRC=${PERCONA_FILE%%\.tar\.gz*}
SPHINX_FILE=${SPHINX_URL##http*/}
SPHINX_SRC=${SPHINX_FILE%%\.tar\.gz*}
GALERA_SRC=${GALERA_URL##http*/}

# Install galera lib ( /usr/lib/galera/libgalera_smm.so)
cd ~
echo "----------------------------------------DL galera lib: wget $GALERA_URL"
#wget $GALERA_URL
echo "----------------------------------------install galera lib: dpkg -i $GALERA_SRC"
sudo dpkg -i $GALERA_SRC

# Download and extract sphinx
cd ~
echo "----------------------------------------DL sphinx: wget $SPHINX_URL"
#wget $SPHINX_URL
echo "----------------------------------------expand sphinx src: wget $SPHINX_FILE"
tar xvfz $SPHINX_FILE


#Install percona cluster
cd ~
echo "----------------------------------------DL percona: wget $PERCONA_URL"
#wget $PERCONA_URL
echo "----------------------------------------expand percona src: wget $PERCONA_FILE"
tar xvfz $PERCONA_FILE
echo "----------------------------------------cd into percona src: cd $PERCONA_SRC"
cd $PERCONA_SRC
echo "----------------------------------------copy sphinx files into percona src: cp -R ~/${SPHINX_SRC}/mysqlse storage/sphinx"
cp -R ~/${SPHINX_SRC}/mysqlse storage/sphinx
echo "----------------------------------------add sphinx flags to percona build script"
sed -i 's/extra_configs="/& --with-sphinx-storage-engine /g' $PERCONA_BUILD_FILE
echo "----------------------------------------add install prefix to percona build script: -DCMAKE_INSTALL_PREFIX=$PERCONA_DEST"
sed -i "s|extra_configs=\"|& --prefix=$PERCONA_DEST |g" $PERCONA_BUILD_FILE
echo "----------------------------------------build and install percona"
"$PERCONA_BUILD_FILE"
sudo make install


# Create mysql directories, if needed
sudo mkdir $PERCONA_BASE_DIR
sudo mkdir $PERCONA_BASE_DIR/data
sudo mkdir $PERCONA_BASE_DIR/tmp
sudo chown -R mysql:mysql $PERCONA_BASE_DIR

# Initialize mysql, if needed
cd $PERCONA_DEST
sudo ./scripts/mysql_install_db --defaults-file=$PERCONA_CNF
sudo cp -R $MYSQL_USER_TABLES "$PERCONA_BASE_DIR/data/" 
sudo chown -R mysql:mysql $PERCONA_BASE_DIR

