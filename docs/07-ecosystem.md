# 07 — Hệ sinh thái Security Onion và khả năng tích hợp

| Thành phần | Chức năng | EVAL của đề tài |
|---|---|---|
| Suricata | NIDS signatures, alerts, packet capture | Có, thành phần trọng tâm |
| Zeek | Protocol analysis, network metadata | Có, thành phần trọng tâm |
| Elasticsearch | Lưu trữ, index, truy vấn | Có |
| Security Onion Console | Alerts, Hunt, Dashboards, PCAP, Cases, Grid | Có |
| Elastic Agent **trên node Security Onion** | Chuyển event nội bộ | Có theo kiến trúc EVAL |
| Elastic Agent **trên Windows endpoint** | Chuyển Windows/Sysmon logs | **Không hỗ trợ thêm vào EVAL** |
| Logstash, Redis | Pipeline/queue ở Standalone/Distributed | **Không chạy trong EVAL** |
| Strelka | Phân tích file được trích xuất khi phù hợp | Nghiên cứu lý thuyết; không đặt là demo bắt buộc |
| Security Onion Pro | Khả năng thương mại bổ sung/ hỗ trợ enterprise | Nghiên cứu, không giả định có license |
| OPNsense / Suricata IPS | Chặn traffic theo cơ chế inline khi cấu hình đúng | Nâng cấp độc lập, không phải chức năng của sensor EVAL |

## Mối liên hệ với yêu cầu “IDPS thương mại”

- Bản demo sử dụng thành phần phát hiện/điều tra trong Security Onion EVAL.
- Phân tích thương mại cần đối chiếu với **Security Onion Pro** từ vendor; không tự gán tính năng bản Pro cho Community.
- Đề tài có chữ IDPS nhưng lab **không chứng minh hành động chặn**. Nếu giảng viên yêu cầu đúng cả Prevention, trình bày thiết kế IPS mở rộng và chỉ đánh dấu “đã thực nghiệm” khi có log drop + traffic bị ngăn chặn.

## Phương hướng mở rộng

1. Thay EVAL bằng Standalone khi Host đủ tài nguyên (vendor tối thiểu 24 GB **cho riêng VM**, thực tế nên cấp cao hơn tùy tải).
2. Tích hợp log Windows/Sysmon qua agent tới deployment có khả năng nhận endpoint logs.
3. Tương quan event Zeek + Suricata + Windows để phân tích hành vi.
4. Bổ sung gateway IPS inline và đối chiếu before/after với traffic thật trong lab.

**Nguồn:** [Architecture](https://docs.securityonion.net/en/3/main/architecture/), [Tools](https://docs.securityonion.net/en/3/main/tools/), [Logstash](https://docs.securityonion.net/en/3/main/logstash/), [Official website](https://securityonion.net/).
