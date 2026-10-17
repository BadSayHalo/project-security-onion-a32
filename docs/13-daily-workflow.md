# 13 — Quick start / shutdown hằng ngày

Mục tiêu: **Windows đã đăng nhập → bật VM Security Onion → SSH tunnel tự kết nối → mở Firefox SO-Lab**. Tác vụ nền trên Windows phải được cấu hình một lần theo [Windows README](../windows/README.md); nếu chưa cấu hình Task Scheduler, chạy thủ công `windows/auto-tunnel.ps1`.

## Mỗi lần bật lab

1. Mở VirtualBox, **Start** Security Onion (không dùng Resume Save State nếu đang cài/cập nhật).
2. Chờ VM boot. Nếu Task Scheduler được cấu hình, `auto-tunnel.ps1` sẽ tự thử SSH tới `127.0.0.1:2222` và mở SOCKS5 cục bộ `127.0.0.1:1080`.
3. Windows PowerShell (tùy chọn để chẩn đoán):

```powershell
Test-NetConnection 127.0.0.1 -Port 2222
Test-NetConnection 127.0.0.1 -Port 1080
curl.exe -k --socks5-hostname 127.0.0.1:1080 --max-time 15 -I https://10.0.2.15/
```

4. Mở Firefox **SO-Lab** profile đã cấu hình SOCKS5 → `https://10.0.2.15`.
5. Khi cần kiểm tra trong VM, SSH quản trị `ssh -p 2222 YOUR_SO_USER@127.0.0.1` và chạy `sudo so-status -q; echo $?`. Sau boot có thể trả `2` tạm thời, chờ rồi đo lại.

**Không mở `https://127.0.0.1:8443` để đăng nhập:** SOC redirect sang guest `10.0.2.15` nên có thể vướng NAT. URL thông qua SOCKS là địa chỉ guest.

## Khi tắt lab

1. Dừng kịch bản demo, kết thúc quá trình thu thập bằng chứng.
2. Tắt SO qua SSH: `sudo shutdown -h now`. Chờ VM tắt hoàn toàn trên VirtualBox.
3. Đóng Firefox SO-Lab nếu không sử dụng. Nếu script tự động chạy tại logon, có thể để chạy và tự reconnect khi VM bật lần tới.
4. Không xóa VDI, không hard reset trong khi SO đang ghi dữ liệu.

## Nếu sau reboot không kết nối

- `2222 Connection refused`: rule NAT SSH hoặc VM chưa sẵn sàng; kiểm tra VirtualBox.
- `2222 OK`, `1080 closed`: `auto-tunnel.ps1` chưa chạy hoặc key chưa hợp lệ; chạy thử thủ công ở terminal để xem thông báo lỗi.
- `1080 OK` nhưng curl SOCKS lỗi: xem host key, SSH forwarding permission và guest service status.
- `curl` HTTP 200/30x nhưng Firefox không mở: kiểm tra profile SOCKS và chứng chỉ.

Chi tiết: [Windows access guide](11-windows-ssh-socks.md) · [Troubleshooting](06-troubleshooting.md).
