# TC-03 — SQL Injection trên OWASP Juice Shop

**Mục tiêu:** Kiểm tra dữ liệu request, response, metadata và khả năng khớp signature từ Suricata đối với ứng dụng được thiết kế để luyện tập bảo mật.

**Scope:** Chỉ OWASP Juice Shop chạy trong Ubuntu VM thuộc `lab-ids`; không sử dụng trang web thật. Dùng tài khoản và dữ liệu giả.

## Chuẩn bị

1. Cài và chạy Juice Shop theo [OWASP Juice Shop](https://owasp.org/www-project-juice-shop/) (nên cài Docker khi bật NAT tạm, sau đó tắt lại nếu có thể).
2. Đảm bảo client Kali truy cập app qua IP lab của Ubuntu.
3. Xác định HTTP/HTTPS: nếu HTTPS, sensor thông thường không thấy body request mã hóa; khi mục đích là phân tích HTTP payload nên dùng HTTP **chỉ trong mạng lab cô lập**.
4. Thực hiện bài tập SQL Injection đã được Juice Shop thiết kế (theo hướng dẫn chính thức), chỉ vào chính ứng dụng lab.
5. Quan sát event ở Zeek/Hunt, Suricata Alerts nếu ruleset match và PCAP (nếu capture được).

## Phân tích

- Request nào được ghi? URL/path/method có nhìn thấy không? Có request body hay không?
- Truy vấn có thực sự được app chấp nhận, hay chỉ được gửi đi?
- Có alert? Rule SID nào và có false positive/negative?
- Điều gì sẽ thay đổi khi traffic dùng HTTPS?

**Observed:** _Chưa chạy_  
**Evidence:** _Chưa có_  
**Verdict:** `NOT_RUN`
