# Evidence — Hướng dẫn lưu bằng chứng

Repo **không** đính kèm PCAP/log/dump thật. Trước khi public, loại bỏ thông tin định danh, mật khẩu, token, dữ liệu web/HTTP nhạy cảm, các bản dump và dữ liệu mạng của người khác.

## Quy ước tên ảnh

`TC-<id>_<YYYYMMDD-HHMM>_<description>.png`, ví dụ `TC-01_20261012-1530_tcpdump.png` — đây chỉ là **ví dụ cách đặt tên**, không phải file đã được tạo.

Mỗi test lưu:

- ID test, thiết bị test, IP giả lập, timestamp và timezone.
- Input: command/flow, phiên bản công cụ/ruleset.
- Output: event/PCAP/SOC screenshot thật, kết quả kiểm chứng.
- Kết luận: PASS/FAIL/INCONCLUSIVE, lý do và giới hạn.

Không đưa ảnh chưa làm sạch, file `.pcap`, `.pcapng`, `.evtx`, raw logs hoặc data dump vào public repository. `.gitignore` được cấu hình chặn các loại file này theo mặc định.
