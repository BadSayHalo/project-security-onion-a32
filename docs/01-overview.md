# 01 — Tổng quan giải pháp & yêu cầu đề tài A32

## Bài toán

Lưu lượng mạng có thể chứa trinh sát, khai thác ứng dụng web hoặc kết nối đáng ngờ. Nhóm thiết kế sensor thụ động sử dụng Security Onion để thu thập evidence, phát hiện theo ruleset và hỗ trợ điều tra.

## IDS và IPS

- **NIDS (Network Intrusion Detection System):** quan sát lưu lượng, phân tích signature và sinh cảnh báo, không nhất thiết can thiệp đường truyền.
- **NIPS (Network Intrusion Prevention System):** kiểm tra lưu lượng theo đường inline và có thể chặn khi rule/action được thiết lập.
- **NSM (Network Security Monitoring):** kết hợp metadata, cảnh báo, PCAP và phân tích để hiểu sự kiện mạng.
- **SOC (Security Onion Console):** giao diện quản trị, Alerts, Dashboards, Hunt, PCAP, Cases và chức năng liên quan.

**Security Onion trong lab này = NIDS + NSM + investigation, KHÔNG phải IPS inline.** Một alert không tương đương một hành động drop.

## Thành phần chính

| Thành phần | Vai trò | Minh chứng |
|---|---|---|
| Suricata | NIDS dựa ruleset/signature; full packet capture khi bật | Alerts, PCAP |
| Zeek | Phân tích giao thức và metadata, như `conn`, `http`, `dns`, `ssl` | Dashboards/Hunt |
| Elasticsearch | Lưu trữ, truy vấn event | Hunt/Dashboards |
| Security Onion Console | Trình điều khiển và phân tích tập trung | Alerts/Hunt/PCAP/Cases |
| Elastic Agent trên node EVAL | Chuyển log nội bộ tới Elasticsearch | Pipeline EVAL |
| Logstash / Redis | Thành phần pipeline ở kiến trúc khác, **không chạy trong EVAL** | Đối chiếu Standalone |

## Commercial / Community

Security Onion kết hợp nhiều thành phần nguồn mở; Security Onion Pro là lựa chọn thương mại với khả năng/hỗ trợ bổ sung. Demo cơ bản trong repo **không giả định quyền truy cập tính năng Pro**, và không khẳng định toàn bộ tính năng Pro đều có trên Community. Khi viết báo cáo, kiểm chứng từng tính năng thương mại ở trang vendor tại thời điểm nộp.

## Ma trận đáp ứng yêu cầu giảng viên

1. **Tính năng:** bảng thành phần và tình huống minh họa.
2. **Nguyên lý & triển khai:** topology, pipeline, yêu cầu phần cứng, mạng quản trị/giám sát.
3. **Demo:** test case rõ input/expected/evidence/actual; screenshots chỉ thêm sau kiểm thử.
4. **Hệ sinh thái:** Suricata, Zeek, Elasticsearch, Elastic Agent, Strelka, Security Onion Pro và IPS ngoài.

## Phạm vi không làm trong giai đoạn 1

- Không triển khai phân tán/HA, không chạy hệ thống production.
- Không cài Elastic Agent Windows gửi về EVAL như thể được hỗ trợ.
- Không thực hiện khai thác ngoài môi trường cô lập, không dùng malware thật để chứng minh C2.

**Nguồn:** [Architecture](https://docs.securityonion.net/en/3/main/architecture/), [Suricata](https://docs.securityonion.net/en/3/main/suricata/), [Zeek](https://docs.securityonion.net/en/3/main/zeek/), [Tools](https://docs.securityonion.net/en/3/main/tools/).
