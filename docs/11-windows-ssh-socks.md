# 11 — Windows → Security Onion SOC: NAT, firewall, SSH key, SOCKS5, Firefox

**Kết quả đã kiểm chứng trên lab:** PowerShell kết nối được tới SSH qua `localhost:2222` không cần mật khẩu, HTTPS `localhost:8443` trả HTTP 307, Firefox/SOCKS đã được người thực hiện xác nhận hoạt động. Hướng dẫn này dùng địa chỉ **ví dụ cụ thể của lab**; nếu đổi VM/IP/user phải thay tương ứng.

## 1. Tổng quan và lý do SOCKS5

```text
Windows Firefox (SOCKS5 127.0.0.1:1080)
        | via SSH dynamic forwarding
Windows SSH 127.0.0.1:2222
        | VirtualBox NAT Port Forwarding
Security Onion NAT guest 10.0.2.15:22
        | SSH server opens connection from inside VM
Security Onion SOC 10.0.2.15:443
```

NAT HTTPS 8443 → 443 **chạy được** nhưng SOC redirect về `https://10.0.2.15/` (không chứa port 8443); Windows Host thông thường không route trực tiếp đến NAT guest IP `10.0.2.15`. SOCKS tunnel giữ nguyên IP/URL của SOC.

## 2. VirtualBox — Adapter 1 Management

- `Adapter 1`: Attached to `NAT` (không phải NAT Network), Cable Connected.
- Đối chiếu `ip -br addr` trong VM: ở lab này management IP là `10.0.2.15`.
- VirtualBox → Settings → Network → Adapter 1 → Advanced → Port Forwarding:

| Name | Protocol | Host IP | Host Port | Guest IP | Guest Port |
|---|---|---|---:|---|---:|
| SSH | TCP | `127.0.0.1` | `2222` | `10.0.2.15` | `22` |
| SOC (optional diag) | TCP | `127.0.0.1` | `8443` | `10.0.2.15` | `443` |

Chỉ bind `127.0.0.1` để không phơi SSH/Web sang các NIC vật lý. Đảm bảo nhấn **OK** đủ các cửa sổ. Nếu guest DHCP đổi IP, cập nhật `Guest IP` hoặc để trống nếu cấu hình VirtualBox cho phép; ưu tiên kiểm chứng IP thực tế.

## 3. Kiểm tra và cấu hình Security Onion firewall

Windows PowerShell:

```powershell
Test-NetConnection 127.0.0.1 -Port 2222
Test-NetConnection 127.0.0.1 -Port 8443
curl.exe -vkI --connect-timeout 5 --max-time 10 https://127.0.0.1:8443/
```

**Không suy luận `TcpTestSucceeded: True` nghĩa là HTTPS/SSH application đã thành công.** Cần có HTTP response thực tế.

Nếu HTTPS treo, từ terminal/SSH Security Onion:

```bash
ip -br addr
sudo ss -lntp | grep ':443'
curl -kI --max-time 10 https://127.0.0.1/
sudo tcpdump -ni enp0s3 'tcp port 443'
```

Trong khi `tcpdump` chạy, từ Windows gửi `curl.exe -vkI --max-time 10 https://127.0.0.1:8443/` để xác định **IP nguồn thật**. Trên lab đã thấy `10.0.2.2`.

```bash
sudo so-firewall includehost analyst 10.0.2.2
sudo salt-call pillar.get firewall:hostgroups:analyst
```

**Dùng IP nguồn vừa đo, không gán mặc định `10.0.2.2` trên mọi hệ thống.** Để Salt tự áp dụng; kiểm tra tác vụ Salt trước khi ép đồng bộ. Lệnh chính thức `sudo so-checkin` chỉ dùng khi không có Salt highstate khác đang chạy. Tuyệt đối không flush iptables hoặc mở `0.0.0.0/0`.

Khi ứng dụng trả `HTTP/1.1 307 Location: https://10.0.2.15/`, port forwarding và firewall HTTPS đã hoạt động. Redirect là hành vi khác với lỗi kết nối.

## 4. SSH key — cấu hình một lần trên Windows

> Thay `YOUR_SO_USER` bằng account hệ điều hành Security Onion của bạn. **Đừng đưa private key vào GitHub.** Nếu đã chạy và có `SSH_OK`, bỏ qua toàn bộ mục này.

```powershell
ssh-keygen -t ed25519 -f "$env:USERPROFILE\.ssh\so_lab_ed25519"
Get-Content "$env:USERPROFILE\.ssh\so_lab_ed25519.pub" |
  ssh -p 2222 YOUR_SO_USER@127.0.0.1 'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys'
ssh -i "$env:USERPROFILE\.ssh\so_lab_ed25519" -o IdentitiesOnly=yes -o BatchMode=yes -p 2222 YOUR_SO_USER@127.0.0.1 'echo SSH_OK'
```

Nếu đã tồn tại key, **không chạy `ssh-keygen` ghi đè**. Nên đặt passphrase và dùng `ssh-agent` nếu có thể; nếu dùng key không passphrase để tự động chạy, giới hạn quyền đọc của key, bảo mật tài khoản Windows và cân nhắc `authorized_keys` với quyền hạn tối thiểu. Kiểm tra **host key fingerprint** trong lần kết nối đầu; dừng lại nếu host key bất ngờ thay đổi.

## 5. Tunnel thủ công — dùng khi debug

```powershell
ssh -N -T -i "$env:USERPROFILE\.ssh\so_lab_ed25519" `
  -o IdentitiesOnly=yes -o BatchMode=yes -o ExitOnForwardFailure=yes `
  -D 127.0.0.1:1080 -p 2222 YOUR_SO_USER@127.0.0.1
```

PowerShell không trả prompt khi tunnel đang chạy là **bình thường**. Mở tab khác:

```powershell
Test-NetConnection 127.0.0.1 -Port 1080
curl.exe -vk --socks5-hostname 127.0.0.1:1080 --max-time 15 https://10.0.2.15/
```

SOCKS5 đã hoạt động nếu `curl.exe` có HTTP response phù hợp; riêng lệnh Test-NetConnection chỉ chứng minh listener cổng 1080.

## 6. Firefox profile riêng cho lab

- Vào `about:profiles` → tạo Firefox profile riêng tên `SO-Lab` nếu cần.
- Settings → Network Settings → Manual proxy → chỉ điền **SOCKS Host `127.0.0.1` Port `1080`**, chọn SOCKS v5; bật proxy DNS nếu dùng hostname trong tương lai.
- Không thêm `10.0.2.15` vào `No proxy for`.
- Mở `https://10.0.2.15` (không phải localhost:8443). Chỉ chấp nhận ngoại lệ certificate sau khi xác nhận đúng máy lab/địa chỉ; cân nhắc certificate tin cậy cho triển khai lâu dài.
- **Không dùng profile proxy này cho duyệt web thường ngày**.

## 7. Tự kết nối sau reboot (Windows)

Chép cấu hình mẫu:

```powershell
Copy-Item .\windows\config.example.ps1 .\windows\config.local.ps1
notepad .\windows\config.local.ps1
```

Điền `SSHUser` trong `config.local.ps1`; file bị `.gitignore` bỏ qua. Chạy thử:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows\auto-tunnel.ps1
```

Script sẽ thử SSH lại khi VM chưa bật, SSH port chưa mở hoặc VM reboot; để nguyên cửa sổ khi chạy thủ công. Xác minh một lần rồi cấu hình **Task Scheduler → At log on → PowerShell -File ...**, `Do not start a new instance` để tránh chiếm lại cổng 1080.

Xem [Windows scripts README](../windows/README.md) và [daily workflow](13-daily-workflow.md).

## 8. Các lỗi thường gặp

| Dấu hiệu | Kiểm tra tiếp |
|---|---|
| `Connection refused` ở 2222 | VM đang bật? rule SSH được lưu? `netstat -ano | findstr :2222`, guest `ss -lntp` port 22 |
| `Test-NetConnection 8443=True` nhưng curl treo | `tcpdump` trên guest, Security Onion host firewall |
| `HTTP 307 Location https://10.0.2.15/` | Dùng SOCKS5 + URL gốc; đừng sửa NIC hay `url_base` vội |
| `SSH_OK` nhưng tunnel không lên | Cổng 1080 bị chiếm? ssh key path/user? Kiểm tra process/host key, tắt các tunnel trùng |
| Firefox proxy báo không kết nối | Script có còn chạy? kiểm tra bằng `curl.exe --socks5-hostname ...` |
| `so-status -q=2` sau boot | Chờ dịch vụ khởi tạo rồi kiểm tra lại; chưa chắc lỗi |

**Nguồn:** [Firewall](https://docs.securityonion.net/en/3/main/firewall/), [Salt](https://docs.securityonion.net/en/3/main/salt/), [URL base](https://docs.securityonion.net/en/3/main/url-base/), [VirtualBox](https://docs.securityonion.net/en/3/main/virtualbox/).
