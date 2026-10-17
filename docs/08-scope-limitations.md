# 08 — Phạm vi, giới hạn và cách diễn đạt kết quả

## Giai đoạn 1: bắt buộc

1. Setup Security Onion EVAL xong và truy cập SOC.
2. Kiểm chứng sensor nhìn thấy traffic từ VM Kali tới Ubuntu.
3. Phân tích metadata kết nối Zeek hoặc Suricata.
4. Demo Alerts khi rule phù hợp, Hunt, PCAP và Cases.
5. Ghi kết quả kiểm thử minh bạch, gồm false negatives/không có alert.

## Giai đoạn 2: tùy chọn

- SQL Injection ứng dụng OWASP Juice Shop trong môi trường cô lập.
- Beaconing giả lập HTTP(S) tới host kiểm thử do nhóm quản lý (không dùng malware thật).
- Windows/Sysmon trong deployment **khác EVAL**.
- IPS inline trên gateway riêng khi có yêu cầu và đủ thời gian/tài nguyên.

## Những khẳng định không nên viết

- ❌ “Security Onion chặn mọi cuộc tấn công theo thời gian thực” — sensor EVAL thụ động không chặn traffic.
- ❌ “Ping luôn tạo Suricata Alert” — ping thường chỉ tạo metadata/capture.
- ❌ “HTTP 403 chứng minh Docker registry hoạt động” — chỉ cho biết endpoint đã trả HTTP.
- ❌ “EVAL nhận Windows Elastic Agent như Standalone” — EVAL không hỗ trợ agent bổ sung.
- ❌ “Mọi kết quả test đều đạt” khi chưa có bằng chứng thực nghiệm.

## Phương pháp đo

- Ground truth: timestamp, nguồn/đích, input của test, thao tác/command, kết quả máy đích.
- Detection: đúng loại event, đúng test, đúng khoảng thời gian; phân biệt **alert** và **metadata**.
- Tính tỉ lệ detection, false positive chỉ khi có đủ dữ liệu test có/không có tấn công và quy tắc khớp rõ ràng.
- Không gán “100% phát hiện” cho một số ít test đơn lẻ.
