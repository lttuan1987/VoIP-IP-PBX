# FreeSWITCH 1.10.12 Installation Script (Ubuntu 22.04)

Script tự động cài đặt và cấu hình **FreeSWITCH 1.10.12** từ source trên **Ubuntu 22.04 LTS**.

## Tính năng

Script sẽ tự động thực hiện các bước sau:

* Cập nhật hệ thống
* Cài đặt toàn bộ dependency cần thiết
* Build và cài đặt:

  * Sofia-SIP
  * SpanDSP
  * libks
  * signalwire-c
* Build và cài đặt FreeSWITCH 1.10.12 từ source
* Kích hoạt `mod_xml_curl`
* Tạo symbolic link cho FreeSWITCH
* Tạo user và group `freeswitch`
* Thiết lập quyền thư mục
* Cài đặt và kích hoạt `systemd service`
* Copy cấu hình FreeSWITCH
* Cấu hình `iptables`
* Cấu hình `Fail2Ban`

---

# Yêu cầu

* Ubuntu 22.04 LTS
* Quyền `root`
* Kết nối Internet
* Git
* Thư mục project:

```
/root/freesip
```

Ví dụ:

```
/root/freesip
├── install.sh
├── copy_config.sh
├── freeswitch.service
└── bin
    ├── iptables.sh
    └── fail2ban.sh
```

---

# Cài đặt

Di chuyển vào thư mục project

```bash
cd /root/freesip
```

Cấp quyền thực thi

```bash
chmod +x install.sh
chmod +x copy_config.sh
chmod +x bin/*.sh
```

Chạy script

```bash
sudo ./install.sh
```

Quá trình build có thể mất từ **10–30 phút** tùy cấu hình máy.

---

# Phiên bản

| Thành phần   | Version                                           |
| ------------ | ------------------------------------------------- |
| FreeSWITCH   | 1.10.12                                           |
| Sofia-SIP    | Latest                                            |
| SpanDSP      | Commit `0d2e6ac65e0e8f53d652665a743015a88bf048d4` |
| libks        | Latest                                            |
| signalwire-c | Latest                                            |

---

# Module được kích hoạt

Script sẽ tự động build và enable:

```
mod_xml_curl
```

---

# Service

Sau khi cài đặt:

Khởi động

```bash
systemctl start freeswitch
```

Dừng

```bash
systemctl stop freeswitch
```

Khởi động lại

```bash
systemctl restart freeswitch
```

Kiểm tra trạng thái

```bash
systemctl status freeswitch
```

Tự khởi động cùng hệ thống

```bash
systemctl enable freeswitch
```

---

# FreeSWITCH CLI

```bash
fs_cli
```

---

# Thư mục cài đặt

```
/usr/local/freeswitch
```

Liên kết cấu hình

```
/etc/freeswitch
```

Binary

```
/usr/bin/fs_cli
/usr/sbin/freeswitch
```

---

# Script sau khi cài đặt

Sau khi FreeSWITCH được build thành công, script sẽ tiếp tục thực hiện:

```text
copy_config.sh
```

* Sao chép cấu hình FreeSWITCH.

```text
bin/iptables.sh
```

* Thiết lập tường lửa.

```text
bin/fail2ban.sh
```

* Cấu hình Fail2Ban để tăng cường bảo mật.

---

# Kiểm tra cài đặt

Kiểm tra service

```bash
systemctl status freeswitch
```

Kiểm tra CLI

```bash
fs_cli
```

Nếu đăng nhập thành công sẽ hiển thị giao diện FreeSWITCH CLI.

---

# Gỡ cài đặt

Script hiện **không hỗ trợ uninstall tự động**.

Nếu cần gỡ bỏ, hãy xóa:

```text
/usr/local/freeswitch
/usr/local/src/freeswitch*
/usr/local/src/sofia-sip
/usr/local/src/spandsp
/usr/local/src/libks
/usr/local/src/signalwire-c
```

Đồng thời xóa:

```bash
systemctl disable freeswitch
rm /etc/systemd/system/freeswitch.service
systemctl daemon-reload
```

---

# Lưu ý

* Script được thiết kế cho **Ubuntu 22.04**.
* Nên chạy trên hệ thống mới cài đặt (fresh install).
* Không khuyến nghị chạy nhiều lần trên cùng một máy chủ đang hoạt động.
* Quá trình build yêu cầu kết nối Internet ổn định để tải source code và các dependency.

---

# License

Dự án được cung cấp dưới giấy phép **MIT License**.

# Contact

Nếu bạn có thắc mắc hoặc muốn hợp tác, hãy liên hệ với chúng tôi:

- Email: lttuan1987@gmail.com
- GitHub: https://github.com/lttuan1987
- GitHub Page: https://lttuan1987.github.io