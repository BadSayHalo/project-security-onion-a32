# 03 — Security Onion 3.3 ISO → EVAL → SOC: Hướng dẫn từng bước

> **Đã hoàn thành trên lab hiện tại.** Tài liệu dưới đây có hai mục tiêu: (1) tái dựng môi trường mới từ ISO; (2) chỉ ra các bước đã thực sự xác minh thành công trong quá trình cài của dự án. Xem [bảng bằng chứng đã xác minh](10-verified-setup.md) và [trạng thái hiện tại](../PROJECT_STATUS.md).

## 1. Kiểm tra điều kiện và chuẩn bị ISO

- Host: Windows, 24 GB RAM, 8 logical processors, VirtualBox.
- Security Onion **EVAL** minimum theo vendor: 4 vCPU, 8 GB RAM, 200 GB disk, 2 network interfaces. Cấu hình **đề xuất** trong dự án: 12 GB RAM / 4 vCPU / 200 GB dynamically allocated. Cần đủ dung lượng **thực** trên SSD Host.
- Truy cập [Download](https://docs.securityonion.net/en/3/main/download/); kiểm tra phiên bản, release notes và **SHA-256 checksum** theo đúng thông tin tải ISO chính thức. Không sử dụng file ISO không rõ nguồn.
- Bật tính năng ảo hóa VT-x/AMD-V trong BIOS/UEFI nếu VirtualBox yêu cầu. Không cần bật nested virtualization cho lab này.

## 2. Tạo VM mới trong VirtualBox

1. **New** → đặt tên dễ nhận diện (ví dụ `Security Onion`).
2. Chọn ISO → đánh dấu **Skip Unattended Installation**.
3. Chọn Linux / Oracle Linux 9.x (nếu VirtualBox nhận diện).
4. RAM `12288 MB`, Processors `4`, virtual disk `200 GB` (dynamic).
5. Settings → Network:
   - Adapter 1: **NAT** (Management), Cable Connected.
   - Adapter 2: bật, dành riêng Monitor. Trong giai đoạn cài có thể giữ Host-Only theo cấu hình đang dùng; sau khi Setup xong **mới** quyết định chuyển sang `Internal Network: lab-ids` nếu phù hợp.
   - Monitor Promiscuous Mode: `Allow VMs` hoặc `Allow All` tùy mô hình; không gán IP cho interface sniffing.
6. Boot ISO → cài Oracle Linux/Security Onion → khi xong reboot và boot từ disk, tháo ISO nếu cần.

## 3. Security Onion Setup Wizard

1. Đăng nhập user đã tạo lúc cài OS. Với ISO, Setup thường tự chạy sau đăng nhập.
2. Chọn `EVAL` (evaluation, all-in-one) và Standard theo wizard nếu có lựa chọn này.
3. Quản trị: card Adapter 1 NAT, DHCP; kiểm tra tên interface đúng bằng `ip -br addr` (tên trong lab ghi nhận là `enp0s3`).
4. Giám sát: chọn Adapter 2 (ví dụ `enp0s8`) riêng, không có IP.
5. Xác nhận **hostname cố định trước Setup** vì Security Onion tạo certificates theo hostname. Dùng email/password SOC riêng; không công bố trên repository.
6. Khi hỏi firewall analysts: chỉ cho nguồn quản trị cần thiết, không mở toàn bộ Internet `0.0.0.0/0`.
7. Chờ hoàn tất, không power off/Save State giữa lúc Salt tải/cấu hình thành phần nếu tránh được.

### Nếu Setup thoát bất ngờ

Từ ISO, theo tài liệu hãng:

```bash
sudo tail -n 120 /root/sosetup.log
sudo SecurityOnion/setup/so-setup iso
```

**Không tự chạy lại** khi `so-status -q` đã thành công. Nếu lệnh `sudo so-setup` báo `command not found`, xem đường dẫn thực tế `ls -l ~/SecurityOnion/setup/so-setup` và loại bản cài, đừng tự chép script không tin cậy vào PATH.

## 4. Xử lý lỗi thực tế từng gặp

| Quan sát | Cách xử lý/giải thích |
|---|---|
| `dnf` kẹt hoặc máy tắt đột ngột | Kiểm tra log và package state; việc làm sạch cache từng được thử, nhưng không nên xóa cache theo thói quen. |
| Docker pull `so-logstash:3.3.0` báo `Connection refused` | Kiểm tra DNS/NAT/registry và `/root/sosetup.log`; `sigs.securityonion.net` trả HTTP 403 **không** xác minh toàn bộ Docker pull hoạt động. |
| Salt/Fleet chạy rất lâu sau Save State | `sudo tail -f /root/sosetup.log` chỉ theo dõi; có lúc Salt báo `Succeeded 38; Failed 0`. Đừng nhầm `tail -f` không có dòng mới với Setup treo. |
| `so-status -q` sau boot trả `2` | Services đang khởi động; theo dõi thêm. Lần kiểm chứng sau trong lab trả `0`. |
| SOC không vào từ Windows | Xem phần NAT/firewall/HTTP redirect tại [11 — Windows access](11-windows-ssh-socks.md). |

**EVAL không vận hành Logstash/Redis theo tài liệu**, không xem thiếu dịch vụ ấy là lỗi nếu chế độ EVAL thực sự đang được sử dụng. Cần phân biệt **image được nhắc trong Setup** với container phải đang chạy.

## 5. Verify thành công

Trong Security Onion VM:

```bash
nproc
free -h
df -h
ip -br addr
sudo so-status
sudo so-status -q; echo $?
curl -kI --max-time 10 https://127.0.0.1/
```

- Lịch sử lab: `so-status` báo các dịch vụ running; `so-status -q` đã cho **`0`**.
- Curl nội bộ HTTPS có 30x tới login, sau đó HTTP 200 khi theo redirect.
- **Không suy ra** giám sát traffic đã thành công cho đến khi bước capture Monitor được kiểm chứng.

## 6. NAT HTTPS + SSH để truy cập Web UI từ Windows

VM đã có: Management IP `10.0.2.15`, guest HTTPS/443 và SSH/22.

Trong VirtualBox → Adapter 1 → Advanced → Port Forwarding:

| Name | Host IP | Host port | Guest IP | Guest port |
|---|---|---:|---|---:|
| `SOC` | `127.0.0.1` | `8443` | `10.0.2.15` | `443` |
| `SSH` | `127.0.0.1` | `2222` | `10.0.2.15` | `22` |

Nếu Windows `curl.exe -vkI https://127.0.0.1:8443/` treo: SO có thể đang chặn nguồn NAT `10.0.2.2` trên firewall. **Chỉ sau khi kiểm tra IP nguồn** trong `sudo tcpdump -ni enp0s3 tcp port 443`, chạy:

```bash
sudo so-firewall includehost analyst 10.0.2.2
sudo salt-call pillar.get firewall:hostgroups:analyst
```

Sau khi Salt state áp dụng, Windows trong lab nhận **HTTP 307** và `Location: https://10.0.2.15/`, nghĩa là HTTPS hoạt động nhưng Windows không route trực tiếp địa chỉ đó. Đây là lý do dùng **SSH SOCKS5** thay vì chỉ NAT port forwarding. Xem hướng dẫn chi tiết và auto-tunnel tại [docs/11](11-windows-ssh-socks.md) và [windows/README](../windows/README.md).

## 7. Vận hành sau reboot

- Bật VM, đợi các dịch vụ ổn định; kiểm tra `sudo so-status -q` khi cần.
- Nếu đã cấu hình Task Scheduler và script Windows, SSH SOCKS sẽ tự reconnect sau khi VM bật.
- Firefox lab profile dùng SOCKS5 `127.0.0.1:1080`; URL **`https://10.0.2.15`**, không phải `https://127.0.0.1:8443`.
- Snapshot sau khi shut down đúng cách để có checkpoint tốt. Không chạy lại wizard Setup vì dịch vụ đã hoàn tất.
- Bước kế tiếp: kiểm tra **`bond0` / `enp0s8`** rồi mới xây dựng Kali và Ubuntu: [docs/12](12-monitoring-next.md).

## 8. References

[Installation](https://docs.securityonion.net/en/3/main/installation/) · [VirtualBox](https://docs.securityonion.net/en/3/main/virtualbox/) · [Hardware](https://docs.securityonion.net/en/3/main/hardware/) · [Firewall](https://docs.securityonion.net/en/3/main/firewall/) · [Salt](https://docs.securityonion.net/en/3/main/salt/) · [Post-installation](https://docs.securityonion.net/en/3/main/post-installation/).
