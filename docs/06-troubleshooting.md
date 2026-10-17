# 06 — Troubleshooting: Setup, Salt, NAT, HTTPS & Monitor

> **Cập nhật trạng thái 17/10/2026:** lỗi Setup được khắc phục; `so-status -q` đã từng trả về `0`; SSH+SOCKS+Firefox đã xác nhận hoạt động. Tài liệu dưới đây dùng để **tái hiện và xử lý lỗi nếu phát sinh lại**, không phải mô tả hệ thống đang hỏng.

## 1. Setup ISO / DNF / Docker pull

```bash
nproc
free -h
df -h
ip -br addr
ip route
getent hosts ghcr.io
curl -Iv --connect-timeout 10 https://ghcr.io/v2/
sudo tail -n 150 /root/sosetup.log
```

Trước đây: Docker pull có `Connection refused` khi xử lý image `so-logstash:3.3.0`; `curl -I sigs.securityonion.net` trả `403`. Phản hồi HTTP 403 cho thấy endpoint đã trả lời; **không** chứng minh đường mạng đến mọi registry hoạt động. Không xóa cache bừa bãi, không chạy lại Setup khi đã hoàn tất. Nếu Setup ISO bị thoát, chỉ khi đã chẩn đoán:

```bash
sudo SecurityOnion/setup/so-setup iso
```

## 2. Theo dõi tiến trình khi màn hình 'đứng'

```bash
sudo tail -f /root/sosetup.log
ps -ef | grep '[s]alt-call'
sudo salt-call saltutil.is_running 'state.*'
```

`tail -f` **luôn chờ dòng log mới**, không phải tự nó chứng minh Setup treo. `Ctrl+C` chỉ dừng terminal đang chạy tail nếu bạn thật sự đang ở lệnh tail. Không bấm Ctrl+C vào terminal Setup/highstate đang hoạt động.

Sau một reboot, `so-status -q = 2` có thể chỉ là starting. Kiểm tra lại sau vài phút, quan sát Salt. Nếu Salt highstate đang chạy, **không chạy thêm `so-checkin`** vì có thể xếp hàng các state và kéo dài quá trình. `so-checkin` (tài liệu chính thức) dùng có điều kiện, sau khi chắc chắn không có job khác.

## 3. SOC local hoạt động nhưng Windows không mở HTTPS

```bash
# Guest SO
sudo ss -lntp | grep ':443'
curl -kI --max-time 10 https://127.0.0.1/
sudo tcpdump -ni enp0s3 tcp port 443
```

```powershell
# Windows Host
Test-NetConnection 127.0.0.1 -Port 8443
curl.exe -vkI --connect-timeout 5 --max-time 10 https://127.0.0.1:8443/
```

Trường hợp lab này: `tcpdump` nhìn thấy SYN `10.0.2.2 → 10.0.2.15:443` không SYN-ACK, nghi firewall. Cách sửa có căn cứ là cấp quyền **IP nguồn quan sát được**:

```bash
sudo so-firewall includehost analyst 10.0.2.2
sudo salt-call pillar.get firewall:hostgroups:analyst
```

Để Salt tự đồng bộ; kiểm tra `sudo so-status` và thử lại HTTP. Không dùng `iptables -F` hay thêm `0.0.0.0/0`. Một lần chạy `so-firewall apply` trong lịch sử đã gây chờ lâu; **không sử dụng như bước thường quy**. Đối với lệnh `so-checkin`, kiểm tra tài liệu [Salt](https://docs.securityonion.net/en/3/main/salt/).

## 4. NAT redirect 307 dù HTTPS đã thông

Windows `curl.exe` đã trả:

```http
HTTP/1.1 307 Temporary Redirect
Location: https://10.0.2.15/
```

Đây là **lỗi khả năng truy cập URL sau redirect**, không phải Docker hay firewall còn chặn 443. Dùng SOCKS5 `127.0.0.1:1080` qua SSH và Firefox vào `https://10.0.2.15` để giữ URL gốc. [Hướng dẫn đầy đủ](11-windows-ssh-socks.md).

## 5. SSH và tự kết nối

- `ssh ...2222 Connection refused`: xem NAT rule SSH + `ss -lntp | grep ':22'` trong guest.
- `ssh -o BatchMode=yes` thất bại: kiểm tra `authorized_keys`, quyền và key path.
- SOCKS port 1080 chiếm bởi process khác: dừng script cũ trước khi chạy phiên mới.
- Windows tác vụ chạy ngầm không hoạt động: chạy script thủ công với terminal visible và đọc lỗi; xem [Windows README](../windows/README.md).

## 6. Monitor lab chưa có traffic

Trước khi thay NIC: [monitor guide](12-monitoring-next.md). `tcpdump` không thấy traffic → kiểm tra VirtualBox Internal Network/Promiscuous/route. `tcpdump` thấy nhưng Hunt trống → kiểm tra status/Zeek/ingest/time range; Suricata không alert với traffic bình thường là có thể chấp nhận.

## 7. Sources

[Hardware](https://docs.securityonion.net/en/3/main/hardware/) · [Firewall](https://docs.securityonion.net/en/3/main/firewall/) · [Salt](https://docs.securityonion.net/en/3/main/salt/) · [Installation](https://docs.securityonion.net/en/3/main/installation/) · [Help/Logs](https://docs.securityonion.net/en/3/main/help/)
