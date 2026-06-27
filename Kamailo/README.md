# Kamailio 6.0 Installation Guide

Hướng dẫn cài đặt **Kamailio 6.0** từ source trên Ubuntu, kèm cấu hình **MySQL**, **MariaDB**, **PostgreSQL** và một số thiết lập cơ bản.

---

## Requirements

Cập nhật hệ thống và cài đặt các gói phụ thuộc:

```bash
apt update

apt install -y \
    git gcc g++ make autoconf pkg-config \
    flex bison \
    libmysqlclient-dev \
    libpq-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libpcre2-dev \
    libjwt-dev \
    libunistring-dev
```

> **Note**
>
> `libunistring-dev` là dependency cần thiết nếu build module `websocket`.

---

# Build Kamailio

```bash
mkdir -p /usr/local/src/kamailio-6.0
cd /usr/local/src/kamailio-6.0

git clone --depth 1 --branch 6.0 https://github.com/kamailio/kamailio.git

cd kamailio
```

Tạo Makefile:

```bash
make include_modules="db_mysql db_postgres dialplan tls jwt websocket" cfg
```

Biên dịch và cài đặt:

```bash
make all
make install
make install-systemd-debian
```

---

# Enable Service

```bash
systemctl daemon-reload
systemctl enable kamailio
```

---

# Build Modules

Có hai cách để chỉ định các module cần biên dịch.

### Cách 1: Sửa file `modules.lst`

```bash
nano -w src/modules.lst
```

Thêm:

```text
include_modules=db_mysql db_postgres dialplan tls jwt websocket
```

Sau đó:

```bash
make cfg
```

---

### Cách 2: Chỉ định trực tiếp khi tạo Makefile

```bash
make include_modules="db_mysql db_postgres dialplan tls jwt websocket" cfg
```

---

## Cài đặt vào thư mục riêng

Nếu muốn toàn bộ Kamailio được cài vào một thư mục riêng:

```bash
make PREFIX="/usr/local/kamailio-devel" \
include_modules="db_mysql dialplan tls" cfg
```

---

# Default Paths

| Thành phần    | Đường dẫn                              |
| ------------- | -------------------------------------- |
| Configuration | `/usr/local/etc/kamailio/kamailio.cfg` |
| Modules       | `/usr/local/lib64/kamailio/modules/`   |
| kamctlrc      | `/usr/local/etc/kamailio/kamctlrc`     |

---

# Configure Systemd

Chỉnh sửa service:

```bash
nano /etc/systemd/system/kamailio.service
```

Thêm hoặc sửa:

```ini
Wants=network-online.target
After=network-online.target mariadb.service
```

Sau đó:

```bash
systemctl daemon-reload
```

---

# Database Configuration

## Tạo Database

Sửa file:

```bash
nano -w /usr/local/etc/kamailio/kamctlrc
```

Sau đó tạo database:

```bash
/usr/local/sbin/kamdbctl create
```

---

# MySQL / MariaDB

## Cài đặt MariaDB

```bash
apt install -y mariadb-server
mysql_secure_installation
```

---

## Cho phép kết nối từ xa

Mở firewall:

```bash
iptables -A INPUT -p tcp --dport 3306 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 3306 -j ACCEPT
```

Hoặc:

```bash
ufw allow 3306/tcp
```

---

### MySQL

```bash
nano /etc/mysql/mysql.conf.d/mysqld.cnf
```

```ini
bind-address = 0.0.0.0
```

---

### MariaDB

```bash
nano /etc/mysql/mariadb.conf.d/50-server.cnf
```

```ini
bind-address = 0.0.0.0
```

---

## Grant quyền

```sql
GRANT ALL PRIVILEGES ON *.* TO 'kamailio'@'%' IDENTIFIED BY 'kamailiorw' WITH GRANT OPTION;

FLUSH PRIVILEGES;
```

---

## Kiểm tra kết nối

```bash
mysql -u root -p
```

Hoặc:

```bash
mysql -h 10.1.2.221 -u kamailio -p kamailio
```

---

# PostgreSQL

## Cho phép kết nối

Mở firewall:

```bash
iptables -A INPUT -p tcp --dport 5432 -j ACCEPT
iptables -A OUTPUT -p tcp --sport 5432 -j ACCEPT
```

---

## Chỉnh Authentication

```bash
nano /etc/postgresql/16/main/pg_hba.conf
```

Đổi:

```text
local   all   all   peer
```

thành:

```text
local   all   all   md5
```

---

## Đặt mật khẩu cho postgres

```bash
sudo -u postgres psql
```

```sql
ALTER USER postgres PASSWORD 'ZiichatKamailio';
```

---

## Tạo file `.pgpass`

```bash
nano ~/.pgpass
```

```text
localhost:5432:kamailio:postgres:ZiichatKamailio
```

```bash
chmod 600 ~/.pgpass
```

---

## Tạo Database

```sql
CREATE DATABASE kamailio;

CREATE USER kamailio
WITH ENCRYPTED PASSWORD 'kamailio_password';

GRANT ALL PRIVILEGES
ON DATABASE kamailio
TO kamailio;
```

---

## Kiểm tra kết nối

```bash
psql -h 10.1.2.221 -U kamailio -d kamailio
```

---

# PostgreSQL Useful Commands

Khởi động dịch vụ:

```bash
systemctl enable postgresql
systemctl start postgresql
systemctl restart postgresql
systemctl status postgresql
```

Mở PostgreSQL shell:

```bash
sudo -u postgres psql
```

Danh sách user:

```sql
\du
```

Đổi database:

```sql
\c postgres
```

Xóa database:

```sql
DROP DATABASE IF EXISTS kamailio;
```

Xóa user:

```sql
DROP ROLE IF EXISTS kamailio;
DROP ROLE IF EXISTS kamailioro;
```

Đổi mật khẩu postgres:

```bash
sudo -u postgres psql -c \
"ALTER USER postgres WITH PASSWORD 'new_password';"
```

---

# Kamailio Service

```bash
systemctl start kamailio
systemctl restart kamailio
systemctl stop kamailio
systemctl status kamailio
```

---

# SIP User Management

Thiết lập `SIP_DOMAIN` trong:

```bash
nano -w /usr/local/etc/kamailio/kamctlrc
```

Hoặc export tạm thời:

```bash
export SIP_DOMAIN=mysipserver.com
```

Tạo tài khoản SIP:

```bash
kamctl add username password
```

---

# Database Notes

Thông tin tài khoản SIP được lưu trong bảng:

```sql
subscriber
```

Có thể kiểm tra bằng:

```sql
SELECT * FROM subscriber;
```

# Contact

Nếu bạn có thắc mắc hoặc muốn hợp tác, hãy liên hệ với chúng tôi:

- Email: lttuan1987@gmail.com
- GitHub: https://github.com/lttuan1987
- GitHub Page: https://lttuan1987.github.io