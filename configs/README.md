# Configurations (non-secret examples)

Các IP/tài nguyên trong repo chỉ là dữ liệu minh họa của VirtualBox lab. Mọi cấu hình user-specific nằm trong file `.local`, `.env` không được commit. Đừng lưu SSH private key, token, password hoặc cookie.

- Windows SOCKS config: [windows/config.example.ps1](../windows/config.example.ps1) → copy thành `config.local.ps1` (ignored).
- `lab-config.example.env`: bản mô tả biến tham khảo, **không** phải tập lệnh tự áp dụng lên host.
- Monitor NIC phải được xác minh thật bằng `ip -br addr` và bond0; không áp dụng cấu hình network hàng loạt khi chưa chụp snapshot.
