#!/bin/bash
set -euo pipefail

# ========================
# Config
# ========================
FREESWITCH_VERSION="1.10.12"
FS_SRC_DIR="/usr/local/src/freeswitch-${FREESWITCH_VERSION}.-release"

# ========================
# Bước 1: Cài đặt dependency
# ========================
export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get upgrade -y
apt install -y build-essential pkg-config uuid-dev zlib1g-dev libjpeg-dev \
  libsqlite3-dev libcurl4-openssl-dev libpcre3-dev libspeex-dev libspeexdsp-dev libldns-dev \
  libedit-dev libtiff5-dev yasm libopus-dev libsndfile1-dev unzip libavformat-dev \
  libswscale-dev liblua5.2-dev liblua5.2-0 cmake libpq-dev unixodbc-dev autoconf \
  automake ntpdate libxml2-dev libpq-dev libpq5 sngrep git subversion libncurses5-dev \
  libssl-dev libasound2-dev libogg-dev libvorbis-dev

rm -rf /usr/local/src/sofia-sip
rm -rf /usr/local/src/spandsp
rm -rf /usr/local/src/libks
rm -rf /usr/local/src/signalwire-c
rm -rf /usr/local/src/freeswitch-${FREESWITCH_VERSION}.-release
rm -rf /usr/local/src/freeswitch-${FREESWITCH_VERSION}.-release.*
rm -rf /usr/local/freeswitch/

# ========================
# Bước 2: Build sofia-sip
# ========================
cd /usr/local/src
git clone https://github.com/freeswitch/sofia-sip.git
cd sofia-sip
./bootstrap.sh
./configure
make -j"$(nproc)"
make install
ldconfig

echo "✅ Waiting ..."
sleep 3

# ========================
# Bước 3: Build spandsp
# ========================
cd /usr/local/src
git clone https://github.com/freeswitch/spandsp.git
cd spandsp
git reset --hard 0d2e6ac65e0e8f53d652665a743015a88bf048d4
./bootstrap.sh
./configure
make -j"$(nproc)"
make install
ldconfig

echo "✅ Waiting ..."
sleep 3

# ========================
# Bước 4: Build libks
# ========================
cd /usr/local/src
git clone https://github.com/signalwire/libks.git
cd libks
cmake .
make -j"$(nproc)"
make install
ldconfig

echo "✅ Waiting ..."
sleep 3

# ========================
# Bước 5: Build signalwire-c
# ========================
cd /usr/local/src
git clone https://github.com/signalwire/signalwire-c.git
cd signalwire-c
cmake .
make -j"$(nproc)"
make install
ldconfig

echo "✅ Waiting ..."
sleep 3

# ========================
# Bước 6: Tải và build freeswitch
# ========================
cd /usr/local/src
wget https://files.freeswitch.org/releases/freeswitch/freeswitch-${FREESWITCH_VERSION}.-release.tar.gz
tar -zxvf freeswitch-${FREESWITCH_VERSION}.-release.tar.gz
cd ${FS_SRC_DIR}
sed -i 's|^#\(xml_int/mod_xml_curl\)|\1|' modules.conf

./configure -C --enable-mod_xml_curl
make -j"$(nproc)"
make install
make sounds-install moh-install
ldconfig

echo "✅ Waiting ..."
sleep 3

# Kích hoạt mod_xml_curl nếu chưa có
XML_FILE=/usr/local/freeswitch/conf/autoload_configs/modules.conf.xml
if grep -q '<!-- *<load module="mod_xml_curl" */> *-->' "$XML_FILE"; then
  sed -i 's/<!-- *<load module=\"mod_xml_curl\" *\/> *-->/<load module=\"mod_xml_curl\"\/>/g' "$XML_FILE"
elif ! grep -q '<load module="mod_xml_curl"/>' "$XML_FILE"; then
  sed -i '/<\/modules>/i\  <load module="mod_xml_curl"/>' "$XML_FILE"
fi

# ========================
# Bước 7: Symlink + user
# ========================
ln -sf /usr/local/freeswitch/conf /etc/freeswitch
ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/fs_cli
ln -sf /usr/local/freeswitch/bin/freeswitch /usr/sbin/freeswitch

# Tạo group nếu chưa tồn tại
getent group freeswitch > /dev/null || groupadd --system freeswitch

# Tạo user nếu chưa tồn tại
id -u freeswitch > /dev/null 2>&1 || \
adduser --quiet --system --home /var/lib/freeswitch \
  --gecos 'FreeSWITCH open source softswitch' \
  --ingroup freeswitch freeswitch --disabled-password --shell /bin/false

# Set quyền nếu thư mục tồn tại
if [ -d /usr/local/freeswitch ]; then
  chown -R freeswitch:freeswitch /usr/local/freeswitch/
  chmod -R ug=rwX,o= /usr/local/freeswitch/
  chmod -R u=rwx,g=rx /usr/local/freeswitch/bin/
fi

cd /root/freesip
cp ./freeswitch.service /etc/systemd/system/freeswitch.service

systemctl daemon-reload
systemctl enable freeswitch
systemctl restart freeswitch
systemctl status freeswitch

# ========================
# Hoàn tất
# ========================
echo "✅ FreeSWITCH ${FREESWITCH_VERSION} đã được cài đặt thành công trên Ubuntu 22.04."

echo "✅ Waiting ..."
sleep 3

./copy_config.sh
echo "✅ Sao chép config FreeSWITCH thành công."

echo "✅ Waiting ..."
sleep 3

./bin/iptables.sh
./bin/fail2ban.sh

echo "✅ Config iptables và fail2ban thành công."