# 04 — Kiểm tra network visibility từ VirtualBox tới SOC

> Bắt đầu phần này **sau khi cài đặt Security Onion hoàn tất**. Nếu đang xử lý Setup, không thay đổi mạng vội.

## 1. Cấu hình mạng thử nghiệm cô lập

VirtualBox: `Internal Network` tên `lab-ids`. Security Onion NIC monitor, Kali và Ubuntu tham gia cùng mạng.

- Kali static IP dự kiến: `192.168.100.10/24`.
- Ubuntu static IP dự kiến: `192.168.100.20/24`.
- NIC monitor của Security Onion: **UP, không gán IP**.
- Không bật bridge trực tiếp tới mạng trường học/công ty; không để app dễ bị tấn công phơi ra Internet.

## 2. Xác định tên interface thực tế

Trên **từng VM**:

```bash
ip -br addr
ip -br link
ip route
```

Không mặc định card luôn là `eth0` hay `enp0s8`: tên có thể thay đổi. Nếu dùng IP tĩnh tạm thời, chỉ làm khi interface chưa có địa chỉ:

```bash
# KALI: THAY <KALI_IF> sau khi xác định đúng interface
sudo ip addr add 192.168.100.10/24 dev <KALI_IF>
sudo ip link set <KALI_IF> up

# UBUNTU: THAY <UBUNTU_IF> sau khi xác định đúng interface
sudo ip addr add 192.168.100.20/24 dev <UBUNTU_IF>
sudo ip link set <UBUNTU_IF> up
```

Lệnh `ip addr add` chỉ là cấu hình tạm, không tồn tại sau reboot. Chọn netplan/NetworkManager nếu muốn lưu vĩnh viễn; giữ backup cấu hình.

## 3. Kiểm tra connectivity

Từ Kali:

```bash
ping -c 4 192.168.100.20
```

Nếu không thông: xem `ip route`, link status, tên Internal Network phải **trùng khớp từng ký tự**, Ubuntu firewall/ICMP.

## 4. Xác minh gói tin ở interface monitor

Trên Security Onion:

```bash
ip -br addr
sudo tcpdump -ni <MONITOR_IF> \
  'host 192.168.100.10 and host 192.168.100.20'
```

Trong thời gian đó, ping tiếp Kali → Ubuntu. Kết quả đạt: thấy gói từ `.10` → `.20` và từ `.20` → `.10`. Kết quả **chỉ có một chiều**: cần điều tra lại visibility, không vội demo IDS.

> Promiscuous Mode VirtualBox không phải bảo đảm tổng quát cho mọi topology. Nếu không thấy gói, cần kiểm tra L2/Internal Network, adapter, driver và có thể chuyển sang mô hình router/gateway kiểm soát đường traffic.

## 5. Kiểm tra từ SOC

Truy cập Dashboards/Hunt. Lọc theo IP hoặc thời gian test, chờ ingest hoàn thành. Zeek thường cho metadata kết nối; **Suricata không bắt buộc báo động với ping thông thường**.

Nếu `tcpdump` thấy nhưng SOC không thấy metadata, kiểm tra `sudo so-status`, Zeek/Suricata logs và filters. Nếu SOC có metadata nhưng không có alert, kiểm tra ruleset và kịch bản trước khi kết luận lỗi.

## 6. Thu thập bằng chứng

Lưu một bản ghi với các trường: UTC timestamp, local timestamp/timezone, nguồn/đích, interface, ảnh `tcpdump`, ảnh Hunt, trạng thái cảnh báo, kết luận. Không đưa packet capture thực tế lên GitHub public khi chưa loại dữ liệu cá nhân.

**Nguồn:** [VirtualBox](https://docs.securityonion.net/en/3/main/virtualbox/), [Suricata troubleshooting](https://docs.securityonion.net/en/3/main/suricata/).
