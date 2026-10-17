# 10 — Nhật ký cài đặt Security Onion 3.3 (đã kiểm chứng)

> **Mục đích:** ghi lại các bước và lỗi **đã thực sự xảy ra trong lab**, đồng thời cung cấp hướng dẫn tái dựng cho nhóm khác. Đây **không phải** bản sao nguyên log hệ thống, không ghi bí mật hoặc giả định nguyên nhân chưa xác minh.

## A. Bối cảnh và môi trường

- Host Windows chạy VirtualBox, RAM 24 GB và **8 logical processors**.
- Phương án khuyến nghị VM Security Onion EVAL: **12 GB RAM / 4 vCPU / 200 GB disk / 2 NIC**. Đây là cấu hình đề xuất; chưa có bản đo hiệu năng thực tế sau khi chỉnh mọi thông số.
- Hệ điều hành theo ISO chính thức Security Onion dựa trên Oracle Linux 9.x; phiên bản nghiên cứu 3.3.0. Không đăng tải ISO hoặc private VM image lên GitHub.
- Adapter 1 Management: NAT, DHCP guest được báo ở `10.0.2.15`.
- Adapter 2 Monitor: có trong kế hoạch, **chưa xác minh trạng thái hiện tại và bond**.

## B. Hướng dẫn tái dựng ISO — chuẩn nhà phát triển

1. Tải ISO Security Onion từ [nguồn chính thức](https://docs.securityonion.net/en/3/main/download/) và **xác minh checksum** theo hướng dẫn phát hành.
2. VirtualBox → New → chọn ISO → bật `Skip Unattended Installation`; chọn Oracle Linux 9.x nếu được nhận diện.
3. Cấp ít nhất 4 vCPU, 8 GB RAM, 200 GB disk, 2 NIC cho **EVAL**; máy lab này đề xuất 12 GB RAM để có dư địa. Theo dõi free space thực tế trên host nếu VDI dynamically allocated.
4. Adapter 1 NAT; Adapter 2 dedicated Monitor (Host-Only giai đoạn cài và debug, sau này hướng `Internal Network` theo topology). Promiscuous `Allow VMs` khi giám sát network VirtualBox; monitor NIC không IP.
5. Boot ISO → cài OS → reboot (eject ISO nếu cần) → đăng nhập → chọn EVAL, Standard, Management DHCP, Monitor đúng interface. **Xác minh hostname trước Setup**: certificate gắn với hostname.
6. Giữ máy chạy trong Setup, hạn chế `Save State`/hard power-off khi đang cập nhật/tải image. Nếu Setup thoát vì lỗi, *chỉ khi nguyên nhân đã được kiểm tra*, dùng:

```bash
sudo tail -n 100 /root/sosetup.log
# Khi cài từ ISO và đang ở home của user setup:
sudo SecurityOnion/setup/so-setup iso
```

Nguồn: [Installation](https://docs.securityonion.net/en/3/main/installation/), [VirtualBox](https://docs.securityonion.net/en/3/main/virtualbox/), [Hardware](https://docs.securityonion.net/en/3/main/hardware/).

## C. Dòng thời gian sự cố và khắc phục trong lab

| Giai đoạn | Quan sát thực tế | Phân tích và cách xử lý |
|---|---|---|
| Setup ban đầu | `dnf` chậm/kẹt, bị power-off đột ngột | Cache DNF từng được làm sạch. Không xem xóa cache là giải pháp mặc định. |
| Docker pull | `Connection refused` khi cài/tải liên quan `so-logstash:3.3.0` | Kết nối mạng có thời điểm bị gián đoạn. `curl -I https://sigs.securityonion.net` nhận `403` chỉ chứng minh endpoint đã phản hồi HTTP, không xác nhận registry/download bình thường. Nguyên nhân chính xác chưa được xác lập từ log trong repo. |
| Setup thoát shell | `sudo so-setup` báo `command not found` | Từ ISO, dùng `sudo SecurityOnion/setup/so-setup iso` theo hướng dẫn chính thức. |
| VirtualBox Save State | Resume khi Salt đang cấu hình Elastic/Fleet, màn hình lâu không đổi | Theo dõi log thay vì Enter/Ctrl+C vào Setup. Kết quả trong ảnh về sau có `Succeeded: 38`, `Failed: 0` (chỉ xác minh **một** lần chạy Salt). |
| Hoàn tất Setup | Banner SOC thông báo HTTPS `https://10.0.2.15` | Web address đã được tạo; kiểm tra thêm trạng thái dịch vụ. |
| Dịch vụ | `so-status` hiển thị container running; lần kiểm tra sau `sudo so-status -q; echo $?` cho `0` | Coi cài EVAL thành công, chưa suy ra packet visibility hoặc IDS alert. |

### Lệnh kiểm chứng sau cài đặt

```bash
nproc
free -h
df -h
ip -br addr
sudo so-status
sudo so-status -q
echo $?
curl -kI --max-time 10 https://127.0.0.1/
```

- `so-status -q = 0`: dịch vụ được kiểm tra đã sẵn sàng ở lần quan sát đó.
- `so-status -q = 2`: các dịch vụ đang khởi động; chờ và kiểm tra lại, không coi lỗi cài ngay.
- Lần xác minh nội bộ, `curl -kIL https://127.0.0.1/` đi qua `307` → `302` → `303` → `200` và redirect tới `https://10.0.2.15/`.

## D. Truy cập SOC từ Windows: chuỗi chẩn đoán đã thực hiện

1. VirtualBox NAT forwarding: `127.0.0.1:8443` → `10.0.2.15:443`.
2. Windows `Test-NetConnection 127.0.0.1 -Port 8443` cho `True` nhưng `curl.exe -vk` ban đầu chưa có HTTP response.
3. `sudo ss -lntp | grep ':443'` trong VM cho port 443 `LISTEN`; curl nội bộ có HTTP response. `tcpdump -ni enp0s3 tcp port 443` thấy SYN của `10.0.2.2` → `10.0.2.15:443` và không thấy SYN-ACK, nghi firewall.
4. Chạy `sudo so-firewall includehost analyst 10.0.2.2`. Pillar kiểm tra thấy `10.0.2.2` trong analyst group.
5. Highstate Salt diễn ra khá lâu; có một thử nghiệm `so-firewall apply` khiến highstate chạy dài. **Không đưa lệnh này vào runbook như bước bắt buộc.** Theo hướng dẫn chính thức, cấu hình được Salt tự áp dụng; `so-checkin` chỉ dùng sau khi xác minh không có highstate khác đang chạy.
6. Sau khởi động lại, `so-status -q` nhận `0`; Windows `curl.exe -vkI ...:8443` trả `HTTP/1.1 307 Temporary Redirect` với `Location: https://10.0.2.15/` → firewall/NAT/TLS đều thông.
7. Cách truy cập ổn định không đổi URL base: SSH key + SOCKS5 127.0.0.1:1080 + Firefox mở `https://10.0.2.15`. Người thực hiện xác nhận hoàn thành cấu hình này.

Xem [hướng dẫn làm lại từng bước](11-windows-ssh-socks.md).

## E. Lưu ý quan trọng

- **Không chạy `iptables -F`**, không mở `0.0.0.0/0` để sửa tạm.
- **Không tiếp tục lặp `so-setup`** khi `so-status -q` đã `0`.
- Không tự kill Salt highstate trong khi đang cấu hình nếu chưa chẩn đoán.
- Không sửa Adapter 1 NAT hoặc `url_base` chỉ để giải quyết redirect khi SOCKS5 đã hoạt động.
- `so-status = 0` ≠ đã thử thành công NIDS/PCAP. Kiểm thử sensor là milestone tiếp theo.

## F. Tài liệu tham chiếu

- [Security Onion 3 — Firewall](https://docs.securityonion.net/en/3/main/firewall/)
- [Security Onion 3 — Salt/so-checkin](https://docs.securityonion.net/en/3/main/salt/)
- [Security Onion 3 — Post-installation](https://docs.securityonion.net/en/3/main/post-installation/)
- [Security Onion 3 — Help/Logs](https://docs.securityonion.net/en/3/main/help/)
