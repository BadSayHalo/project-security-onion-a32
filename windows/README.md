# Windows helper scripts — SSH SOCKS Auto-Connect

Giúp **bật VM → tự kết nối SSH tunnel → Firefox SOC**, không cần gõ lệnh SSH mỗi lần. Dự án không tự thay đổi firewall hoặc VM, không tự thay đổi ExecutionPolicy toàn máy.

## Tiền điều kiện

- Port Forwarding NAT đã kiểm chứng: `localhost:2222` → `10.0.2.15:22`.
- SSH key đã cài trong `~/.ssh/authorized_keys` của user SO; test bằng `ssh -o BatchMode=yes ... 'echo SSH_OK'`.
- Lần đầu SSH đã kiểm tra và chấp nhận **host key hợp lệ** (script mặc định `StrictHostKeyChecking=yes`); không bỏ qua cảnh báo host key thay đổi.
- Windows đã có `ssh.exe` (OpenSSH Client).

## Thiết lập một lần

Từ PowerShell trong **thư mục repo**:

```powershell
Copy-Item .\windows\config.example.ps1 .\windows\config.local.ps1
notepad .\windows\config.local.ps1
```

Thay `YOUR_SO_USER` thành user của VM; đường dẫn key mặc định là `%USERPROFILE%\.ssh\so_lab_ed25519`. `config.local.ps1` không được commit lên GitHub.

### Thử chạy thủ công

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows\auto-tunnel.ps1
```

Cửa sổ PowerShell không trả prompt khi SSH đang chạy là **bình thường**. Cửa sổ này phải tiếp tục mở nếu chạy thủ công; script sẽ tự thử lại nếu VM chưa bật hoặc SSH bị mất. Dừng bằng `Ctrl+C` trong cửa sổ này.

Mở PowerShell khác:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\windows\check-tunnel.ps1
```

Nếu thấy `SOCKS` sẵn sàng, hãy vào Firefox profile SO-Lab tại `https://10.0.2.15`.

### Tự chạy khi Windows đăng nhập

Để script ở đường dẫn **cố định** như `C:\SO-Lab\security-onion-a32-lab\windows\auto-tunnel.ps1`, đừng di chuyển repo sau khi tạo task.

Trong **Task Scheduler → Create Task**:

1. General → Name `SO Lab Auto Tunnel` → `Run only when user is logged on` → user Windows hiện tại, không cần admin.
2. Triggers → `At log on` (current user).
3. Actions → `Start a program`; Program: `powershell.exe`; Arguments (đổi đường dẫn nếu khác):

```text
-NoProfile -NonInteractive -WindowStyle Hidden -File "C:\SO-Lab\security-onion-a32-lab\windows\auto-tunnel.ps1"
```

4. Settings → Nếu task đã chạy, **Do not start a new instance**; không giới hạn thời gian chạy task nếu có tùy chọn tự dừng sau 3 ngày; điều chỉnh Conditions nếu chạy laptop pin.
5. Click Run thử, sau đó `check-tunnel.ps1` xác nhận. Không chạy thêm phiên auto-tunnel thủ công song song vì port `1080` sẽ xung đột.

## Bảo mật

- SSH SOCKS chỉ lắng nghe `127.0.0.1:1080`; NAT forward chỉ bind `127.0.0.1`.
- Chưa bật port `2222`/`1080` cho Internet hoặc LAN.
- Private key **không** đưa vào repo; `config.local.ps1` bị ignore. Nếu SSH key không có passphrase, cần bảo vệ tài khoản Windows và quyền file.
- Nếu hostname/VM thay đổi, host key fingerprint có thể thay đổi: xác minh out-of-band, không xóa toàn bộ known_hosts để 'cho chạy'.

Xem [đầy đủ NAT/firewall/login guide](../docs/11-windows-ssh-socks.md).
