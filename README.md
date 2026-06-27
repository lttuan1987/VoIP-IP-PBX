# VoIP-IP-PBX

Một bộ sưu tập tài liệu, script và hướng dẫn triển khai các hệ thống **VoIP**, **IP PBX** và **SIP Server** trên nền Linux.

Repository này được xây dựng nhằm giúp việc cài đặt, cấu hình và quản trị các nền tảng VoIP phổ biến trở nên đơn giản và dễ tái sử dụng.

---

## Repository Structure

```text
VoIP-IP-PBX
├── README.md
├── freeswitch
│   ├── README.md
│   └── ...
├── asterisk
│   ├── README.md
│   └── ...
└── kamailio
    ├── README.md
    └── ...
```

---

## Available Projects

### FreeSWITCH

FreeSWITCH là một nền tảng Softswitch mã nguồn mở mạnh mẽ, phù hợp cho VoIP, SIP Server, Contact Center và các hệ thống truyền thông thời gian thực.

Nội dung bao gồm:

* Cài đặt từ source
* Build các dependency
* Cấu hình XML
* mod_xml_curl
* Systemd Service
* Firewall
* Fail2Ban
* Các script tự động hóa

👉 Xem tài liệu:

```text
[FreeSWITCH/README.md](https://github.com/lttuan1987/VoIP-IP-PBX/blob/main/FreeSWITCH/README.md)
```

---

### Asterisk

Asterisk là IP PBX mã nguồn mở phổ biến, phù hợp cho tổng đài doanh nghiệp và hệ thống thoại SIP.

Tài liệu sẽ bao gồm:

* Cài đặt
* Cấu hình SIP
* Dialplan
* Extensions
* Trunk
* AGI
* Database
* Security

👉 Xem tài liệu:

```text
[Asterisk-FreePBX/README.md](https://github.com/lttuan1987/VoIP-IP-PBX/blob/main/Asterisk-FreePBX/README.md)
```

---

### Kamailio

Kamailio là SIP Proxy/SIP Router hiệu năng cao, thường được sử dụng cho hệ thống VoIP quy mô lớn.

Tài liệu sẽ bao gồm:

* Cài đặt
* SIP Proxy
* Registrar
* Load Balancing
* Authentication
* Database
* NAT Traversal
* Security

👉 Xem tài liệu:

```text
[Kamailio/README.md](https://github.com/lttuan1987/VoIP-IP-PBX/blob/main/Kamailo/README.md)
```

---

## Mục tiêu của Repository

Repository hướng đến việc:

* Chuẩn hóa quy trình triển khai VoIP.
* Tự động hóa quá trình cài đặt bằng Bash Script.
* Lưu trữ các cấu hình thực tế đã được kiểm thử.
* Chia sẻ kinh nghiệm triển khai và vận hành hệ thống VoIP.

---

## Yêu cầu

Phần lớn tài liệu trong repository được xây dựng cho:

* Ubuntu Server 22.04 LTS
* Debian Linux
* Quyền `root` hoặc `sudo`
* Git

---

## Đóng góp

Mọi đóng góp dưới dạng:

* Pull Request
* Issue
* Bug Report
* Tài liệu
* Script

đều được hoan nghênh.

---

## License

Repository này được phát hành theo **MIT License**.

## Contact

Nếu bạn có thắc mắc hoặc muốn hợp tác, hãy liên hệ với chúng tôi:

- Email: lttuan1987@gmail.com
- GitHub: https://github.com/lttuan1987
- GitHub Page: https://lttuan1987.github.io