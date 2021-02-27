#!/bin/bash

set -e
set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ETC_DIR="/etc"
PKG_DIR="/pkg-debian"
OPT_DIR="/opt/magicmouse-hid"

DEB="magicmouse-hid_1.1.0-0.deb"

cp -rf ${DIR}${ETC_DIR} ${DIR}${PKG_DIR}

mkdir -p ${DIR}${PKG_DIR}${OPT_DIR}
# Copy scripts to /opt
cp -f ${DIR}/scripts/magic-mouse-2-add.sh ${DIR}${PKG_DIR}${OPT_DIR}/magic-mouse-2-add.sh
# cp -f ${DIR}/install.sh ${DIR}${PKG_DIR}${OPT_DIR}/install.sh
# cp -f ${DIR}/remove.sh ${DIR}${PKG_DIR}${OPT_DIR}/remove.sh

mkdir -p ${DIR}${PKG_DIR}${OPT_DIR}/scripts
cp -f ${DIR}/scripts/install.sh ${DIR}${PKG_DIR}${OPT_DIR}/scripts/install.sh
cp -f ${DIR}/scripts/remove.sh ${DIR}${PKG_DIR}${OPT_DIR}/scripts/remove.sh

# Copy source to /opt
cp -rf ${DIR}/linux ${DIR}${PKG_DIR}${OPT_DIR}/linux

# Generate MD5sums
cd ${DIR}${PKG_DIR}
find ${DIR}${PKG_DIR} -type f ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > ${DIR}${PKG_DIR}/DEBIAN/md5sums
cd ${DIR}

# Set correct permissions
chmod 0775 ${DIR}${PKG_DIR}/DEBIAN/postinst
chmod 0775 ${DIR}${PKG_DIR}/DEBIAN/prerm

dpkg -b ${DIR}${PKG_DIR} ${DIR}/${DEB}

dpkg -I ${DIR}/${DEB}