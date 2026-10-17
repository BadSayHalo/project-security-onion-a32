# Setup evidence checklist — mẫu ghi nhận dành cho báo cáo A32

> Không upload cookie, mật khẩu, SSH private key, CSRF token hay PCAP thật chưa khử nhạy cảm lên repo public.

| Mục | Bằng chứng tối thiểu | Tình trạng |
|---|---|---|
| Tải/cài ISO Security Onion 3 | URL tải, checksum đã verify, cấu hình VM | Cần bổ sung ảnh riêng đã kiểm duyệt |
| VirtualBox network | 2 NIC, NAT rule SSH/HTTPS (không có secrets) | Cần bổ sung ảnh riêng đã kiểm duyệt |
| Dịch vụ SO | `sudo so-status -q; echo $?` trả `0` | Đã có kết quả trong hội thoại, cần lưu lại ảnh riêng |
| Firewall | Pillar analyst có IP NAT gateway `10.0.2.2` | Đã có output trong hội thoại |
| HTTPS | Windows curl trả HTTP 307 tới `https://10.0.2.15/` | Đã có output trong hội thoại |
| SSH key | `SSH_OK` (không hiển thị private/public key) | Đã có output trong hội thoại |
| Firefox/SOCKS | Trang SOC hiển thị qua URL nội bộ | Người dùng xác nhận; cần ảnh nếu đưa báo cáo |
| Sensor monitor | IP/link/bond status | NOT_RUN |
| Kali/Ubuntu capture | `tcpdump` hai chiều + Hunt | NOT_RUN |

Mỗi hình minh chứng: ID, mô tả, ngày giờ, phiên bản OS/SO, kết quả và kết luận. Chỉ commit ảnh sau khi xóa thông tin nhạy cảm.
