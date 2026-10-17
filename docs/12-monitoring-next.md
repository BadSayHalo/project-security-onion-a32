# 12 — Bước tiếp: Monitor NIC → Kali/Ubuntu lab (CHƯA CHẠY)

> **Trạng thái:** Planned. Không chỉnh Adapter 1 NAT (đã chạy SSH/SOC ổn định). Chỉ sửa Monitor NIC sau khi đọc output kiểm tra. Tạo snapshot VM khi đã tắt an toàn.

## Phase 1: Quan sát trạng thái hiện có (read-only)

```bash
ip -br addr
ip -br link
ip route
cat /proc/net/bonding/bond0 2>/dev/null || echo 'bond0 not present'
sudo so-status -q; echo $?
```

- Đối chiếu Management NIC (ví dụ `enp0s3`, `10.0.2.15/24`).
- Tìm Monitor NIC thứ hai (ví dụ `enp0s8`), xác minh **không gán IP**.
- Kiểm tra xem `bond0` có tồn tại và Monitor NIC có nằm trong bond hay chưa; nhiều ISO deployment sử dụng bond0 để sniff.
- Nếu Monitor chưa được gắn, tham khảo chính thức [`so-monitor-add`](https://docs.securityonion.net/en/3/main/so-monitor-add/) sau khi backup và xác minh interface; không gọi lệnh để thử mò.

## Phase 2: Cấu hình VirtualBox khi đã đủ bằng chứng

1. Tắt Security Onion theo đúng quy trình (`sudo shutdown -h now`), chờ dừng rồi chụp snapshot.
2. VirtualBox → Security Onion → Adapter 2 → `Internal Network` → Name `lab-ids` → Promiscuous `Allow VMs` → Cable Connected.
3. Adapter 1 NAT **giữ nguyên** 8443/2222; bật lại SO, xác minh SSH tunnel và SOC.
4. Nếu vì mục tiêu giảm rủi ro đổi mạng chưa thuận lợi, Host-Only hiện hữu cũng có thể dùng để thử capture; ưu tiên **đo** visibility rồi mới quyết định thay.

| VM | NIC chính | IP dự kiến |
|---|---|---|
| Security Onion | Adapter 1 NAT / Adapter 2 monitor (Internal Network) | 10.0.2.15 / Monitor không IP |
| Kali | Internal Network `lab-ids` | 192.168.100.10/24 |
| Ubuntu Server | Internal Network `lab-ids` | 192.168.100.20/24 |

## Phase 3: Kiểm thử traffic (tối thiểu)

Trên Kali và Ubuntu, xác định đúng tên interface (`ip -br addr`). Tạm đặt IP bằng các lệnh bên dưới **chỉ khi interface chưa có IP**:

```bash
# Kali (THAY IF_KALI bằng đúng interface)
sudo ip addr add 192.168.100.10/24 dev IF_KALI
sudo ip link set IF_KALI up

# Ubuntu (THAY IF_UBUNTU bằng đúng interface)
sudo ip addr add 192.168.100.20/24 dev IF_UBUNTU
sudo ip link set IF_UBUNTU up
```

Trên Kali: `ping -c 4 192.168.100.20`. Trên SO, chọn đúng monitor NIC hoặc `bond0` nếu thực sự có:

```bash
sudo tcpdump -ni bond0 'host 192.168.100.10 and host 192.168.100.20'
# Hoặc -i enp0s8 nếu bond0 không tồn tại và interface đó được cấu hình sniff thực tế.
```

Điều kiện thành công đầu tiên: thấy cả Echo Request và Echo Reply. Sau đó vào SOC → Hunt tìm Zeek network metadata theo địa chỉ IP và cửa sổ thời gian test.

## Nếu không thấy traffic

- Kiểm tra 3 VM gắn đúng **một** tên Internal Network, cable connected và NIC `UP`.
- Kiểm tra traffic thật sự đi qua lab NIC, không bị NAT NIC route ngoài ý muốn.
- Đừng kỳ vọng promiscuous mode luôn mirror mọi topology; kiểm chứng packet capture rồi điều chỉnh kiến trúc routing/tap nếu cần.
- Không đặt Security Onion inline/IPS; monitor sniff thụ động không chặn traffic.

## Acceptance checklist

- [ ] Có ảnh `ip -br addr` và `bond0`/monitor membership (đã che thông tin không cần thiết).
- [ ] Snapshot VM trước khi đổi Adapter 2.
- [ ] SSH/SOC còn hoạt động sau đổi mạng.
- [ ] Kali ping Ubuntu qua `lab-ids`.
- [ ] `tcpdump` trên SO thấy hai chiều.
- [ ] Zeek metadata xuất hiện trong Hunt (sau khi ingest xong).

**Đừng chuyển trạng thái milestone thành Verified cho tới khi có kết quả thực tế.**

Nguồn: [VirtualBox](https://docs.securityonion.net/en/3/main/virtualbox/), [so-monitor-add](https://docs.securityonion.net/en/3/main/so-monitor-add/), [Grid](https://docs.securityonion.net/en/3/main/grid/).
