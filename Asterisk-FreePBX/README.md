# Asterisk 20 + FreePBX 16 Installation Guide

Hướng dẫn cài đặt **Asterisk 20.11** và **FreePBX 16** trên **Ubuntu Server 20.04.6 LTS**.

---

# Environment

| Component     | Version     |
| ------------- | ----------- |
| Ubuntu Server | 20.04.6 LTS |
| Asterisk      | 20.11       |
| FreePBX       | 16.0        |

---

# Install Asterisk

## Install Dependencies

```bash
apt update

apt install -y \
    unzip git sox curl gnupg2 \
    build-essential \
    libssl-dev \
    libnewt-dev \
    libncurses5-dev \
    libsqlite3-dev \
    libjansson-dev \
    libxml2-dev \
    libedit-dev \
    uuid-dev \
    subversion
```

---

## Download & Build

```bash
wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-20-current.tar.gz

tar -xzf asterisk-20-current.tar.gz

cd asterisk-20.11.0
```

Cài thêm MP3 codec:

```bash
contrib/scripts/get_mp3_source.sh
```

Cài dependency còn thiếu:

```bash
contrib/scripts/install_prereq install
```

Configure:

```bash
./configure
```

Mở giao diện lựa chọn module:

```bash
make menuselect
```

Enable các module:

| Category     | Module           |
| ------------ | ---------------- |
| Add-ons      | chan_ooh323      |
| Add-ons      | format_mp3       |
| Add-ons      | res_config_mysql |
| Applications | app_macro        |

Build:

```bash
make -j$(nproc)

make install
make samples
make config

ldconfig
```

---

# Configure Asterisk

## Create User

```bash
groupadd asterisk

useradd -r \
-d /var/lib/asterisk \
-g asterisk \
asterisk
```

---

## Permissions

```bash
chown -R asterisk:asterisk /etc/asterisk

chown -R asterisk:asterisk \
/var/lib/asterisk \
/var/log/asterisk \
/var/spool/asterisk

chown -R asterisk:asterisk \
/usr/lib/asterisk
```

---

## Configure Default User

File:

```text
/etc/default/asterisk
```

```ini
AST_USER="asterisk"
AST_GROUP="asterisk"
```

---

## Configure asterisk.conf

File:

```text
/etc/asterisk/asterisk.conf
```

```ini
runuser = asterisk
rungroup = asterisk
```

---

## Start Service

```bash
systemctl restart asterisk

systemctl enable asterisk
```

---

# Radius Error

Nếu xuất hiện lỗi:

```text
radcli: can't open radiusclient.conf
```

Sửa:

```bash
sed -i 's";\[radius\]"\[radius\]"g' \
/etc/asterisk/cdr.conf

sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' \
/etc/asterisk/cdr.conf

sed -i 's";radiuscfg => /usr/local/etc/radiusclient-ng/radiusclient.conf"radiuscfg => /etc/radcli/radiusclient.conf"g' \
/etc/asterisk/cel.conf
```

---

# Install FreePBX

## Install PHP & Apache

```bash
apt install -y software-properties-common

add-apt-repository ppa:ondrej/php

apt update
```

Cài PHP 7.4:

```bash
apt install -y \
apache2 \
mariadb-server \
libapache2-mod-php7.4 \
php7.4 \
php7.4-cgi \
php7.4-common \
php7.4-curl \
php7.4-mysql \
php7.4-mbstring \
php7.4-gd \
php7.4-bcmath \
php7.4-zip \
php7.4-xml \
php7.4-imap \
php7.4-snmp \
php-pear
```

---

## Install FreePBX

```bash
wget http://mirror.freepbx.org/modules/packages/freepbx/freepbx-16.0-latest.tgz

tar -xzf freepbx-16.0-latest.tgz

cd freepbx
```

```bash
apt install -y nodejs npm

service mysql start

./install -n
```

---

## Install PM2

```bash
fwconsole ma install pm2
```

---

## Apache Configuration

Đổi Apache chạy bằng user `asterisk`:

```bash
sed -i 's/^\(User\|Group\).*/\1 asterisk/' \
/etc/apache2/apache2.conf
```

Enable Rewrite:

```bash
sed -i 's/AllowOverride None/AllowOverride All/' \
/etc/apache2/apache2.conf

a2enmod rewrite
```

Tăng upload size:

```bash
sed -i 's/^\(upload_max_filesize = \).*/\120M/' \
/etc/php/7.4/apache2/php.ini

sed -i 's/^\(upload_max_filesize = \).*/\120M/' \
/etc/php/7.4/cli/php.ini
```

Restart:

```bash
systemctl restart apache2
```

---

# Login FreePBX

```
http://SERVER_IP/admin
```

---

# Recommended Settings

## NAT

```
Settings
└── Asterisk SIP Settings
    └── NAT Settings
        └── Detect Network Settings
```

---

## Enable CDR

```
Settings
└── Advanced Settings
    └── Enable CDR Logging
```

→ YES

---

## Extension

```
Applications
└── Extensions
    └── Advanced
        └── Direct Media
```

→ NO

---

## Video Call

```
Settings
└── Asterisk SIP Settings
    └── Video Support
```

→ YES

Sau đó chọn codec phù hợp.

---

# HTTPS

Tạo SSL Self-signed:

```bash
openssl genpkey \
-algorithm RSA \
-out /etc/ssl/private/freepbx.key

openssl req \
-new \
-key /etc/ssl/private/freepbx.key \
-out /etc/ssl/certs/freepbx.csr

openssl x509 \
-req \
-days 365 \
-signkey /etc/ssl/private/freepbx.key \
-in /etc/ssl/certs/freepbx.csr \
-out /etc/ssl/certs/freepbx.crt
```

Enable SSL:

```bash
a2enmod ssl

a2ensite default-ssl.conf

systemctl restart apache2
```

---

# ODBC

Cài:

```bash
apt install unixodbc
```

Sau đó cấu hình:

* `/etc/odbc.ini`
* `/etc/odbcinst.ini`
* `/etc/asterisk/res_odbc_additional.conf`
* `/etc/asterisk/cdr_odbc.conf`
* `/etc/asterisk/cdr_adaptive_odbc.conf`

Kiểm tra kết nối:

```bash
isql -v MySQL-asteriskcdrdb <username> <password>
```

---

# Useful Commands

Khởi động dịch vụ:

```bash
systemctl restart mysql
systemctl restart mariadb
systemctl restart apache2
systemctl restart asterisk
```

Kiểm tra trạng thái:

```bash
systemctl status mysql
systemctl status mariadb
systemctl status apache2
systemctl status asterisk
```

Asterisk CLI:

```bash
asterisk -rvvvvv
```

Kiểm tra endpoint:

```bash
asterisk -rx "pjsip show endpoint 6001"
```

Danh sách module:

```bash
nano /etc/asterisk/modules.conf
```

---

# ARI (Asterisk REST Interface)

File:

```text
/etc/asterisk/ari.conf
```

```ini
[general]
enabled=yes
pretty=yes

[api_user]
type=user
read_only=no
password=your_password
```

Reload:

```bash
asterisk -rx "core reload"
```

Kiểm tra HTTP:

```bash
asterisk -rx "http show status"
```

Nếu `Server Disabled`, cần bật HTTP server trong `http.conf`.

# Contact

Nếu bạn có thắc mắc hoặc muốn hợp tác, hãy liên hệ với chúng tôi:

- Email: lttuan1987@gmail.com
- GitHub: https://github.com/lttuan1987
- GitHub Page: https://lttuan1987.github.io