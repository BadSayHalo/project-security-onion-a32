# TC-05 — Mô phỏng kết nối định kỳ vô hại (tùy chọn)

**Mục tiêu:** Phân tích khoảng cách thời gian giữa các kết nối, **không mô phỏng chiếm quyền điều khiển hay dùng payload độc hại**.

1. Trên Ubuntu tạo một HTTP server đơn giản trong lab: `python3 -m http.server 8000 --bind 192.168.100.20`.
2. Trên Kali, gửi một số yêu cầu HTTP GET định kỳ bằng script bên dưới tới **đúng** địa chỉ đã được phép:

```bash
for i in 1 2 3 4 5 6; do
  date -u +%FT%TZ
  curl -fsS --max-time 3 http://192.168.100.20:8000/ >/dev/null
  sleep 15
done
```

3. Trong Hunt xem chuỗi event và timestamp, tính chênh lệch thời gian giữa requests.

**Kết luận đúng:** Metadata kết nối xuất hiện theo chu kỳ trong test này; **không đủ căn cứ khẳng định đã phát hiện mã độc/C2** và không chắc có Suricata alert.

**Observed:** _Chưa chạy_  
**Verdict:** `NOT_RUN`
