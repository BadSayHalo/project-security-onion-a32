# Project status — A32 Security Onion Lab

_Last evidence checkpoint: 2026-10-17 (UTC+07). Trạng thái do người triển khai cung cấp trong cuộc trao đổi, không phải CI kiểm tra vào VM._

| Hạng mục | Trạng thái | Bằng chứng / giới hạn |
|---|---|---|
| ISO cài và Setup EVAL | ✅ Verified | Đã thấy Salt chạy xong `Failed: 0`, thông báo SOC web address |
| Service health | ✅ Verified | `sudo so-status -q` gần nhất trả `0` |
| Management NIC | ✅ Verified | `10.0.2.15` trên NAT được SOC tự công bố và HTTPS phản hồi |
| NAT port forwarding HTTPS 8443 | ✅ Verified | Windows `curl.exe` nhận HTTP `307` từ nginx |
| NAT port forwarding SSH 2222 | ✅ Verified | Windows SSH login thành công |
| Firewall hostgroup analyst | ✅ Verified | Pillar đã có `10.0.2.2`, sau đó HTTPS phản hồi từ Windows |
| SSH public key | ✅ Verified | `ssh -i ... -o BatchMode=yes ... echo SSH_OK` trả `SSH_OK` |
| SOCKS tunnel & Firefox | ✅ User confirmed | Người dùng xác nhận đã làm xong auto-tunnel và browser access; không có log kiểm chứng lần chạy gần nhất |
| Windows auto-start at login | ⚪ Not verified | Chưa xác nhận Task Scheduler đã đăng ký; manual `.ps1` có thể chạy |
| Interface Monitor (`enp0s8`/`bond0`) | ⏳ Pending inspection | Chưa có output `ip -br addr`/`/proc/net/bonding/bond0` |
| Kali/Ubuntu (`lab-ids`) | ⏳ Planned | Dải `192.168.100.0/24` là dự kiến |
| Test cases / alerts / PCAP | ⏳ NOT_RUN | Chưa có kết quả thực nghiệm |

## Next action

Qua SSH, chạy lệnh **chỉ đọc**:

```bash
ip -br addr
ip -br link
cat /proc/net/bonding/bond0 2>/dev/null || echo 'bond0 not present'
sudo so-status -q; echo $?
```

Đọc [docs/12-monitoring-next.md](docs/12-monitoring-next.md). **Không đổi Adapter 2** hoặc chạy `so-monitor-add` trước khi xác minh monitor config; **không thay Adapter 1 NAT** đã hoạt động.

## Review checkpoint

Mỗi khi hoàn tất một milestone, cập nhật trạng thái theo 3 mức: **Verified** (có bằng chứng), **Reported** (người dùng xác nhận), **Planned** (chưa thử). Không đưa các kết quả dự kiến vào cột Verified.
