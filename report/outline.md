# Dàn ý báo cáo đề tài A32 — Security Onion

## Bìa và thông tin nhóm

Tên trường/học phần, mã đề tài A32, tên đề tài, thành viên, giảng viên, thời gian thực hiện (điền sau, không đoán).

## Chương 1. Tổng quan IDPS và Security Onion

- IDS/NIDS/HIDS/IPS, NSM, các thành phần chính.
- Security Onion Community và Security Onion Pro (giới hạn bản demo).
- Mục tiêu, phạm vi, rủi ro và nội dung đề tài.

## Chương 2. Nguyên lý và kiến trúc

- Suricata, Zeek, Elasticsearch và Security Onion Console.
- Sơ đồ luồng dữ liệu EVAL; lý do không dùng Logstash/Redis trong EVAL.
- Các mô hình EVAL / Standalone / Distributed và yêu cầu tối thiểu.

## Chương 3. Thiết kế, triển khai

- Cấu hình Host: 24 GB RAM, 8 logical processors, VirtualBox.
- Topology, địa chỉ IP dự kiến, NAT Management / Monitor Internal Network.
- Quy trình ISO/Setup, xác nhận `so-status`, khắc phục sự cố từ log.
- Tiêu chí kiểm tra packet visibility.

## Chương 4. Demo và đánh giá

- Mô tả từng test case (TC-01 tới TC-04, TC-05 tùy chọn).
- Evidence thật: screenshots, event, rule SID, PCAP nếu có.
- Bảng đánh giá phát hiện; phân biệt metadata và IDS alert.
- Hạn chế khi bật HTTPS, false positives / false negatives.

## Chương 5. Hệ sinh thái, hạn chế và hướng phát triển

- Security Onion Pro, Zeek, Suricata, Elastic Agent, Strelka.
- EVAL so với Standalone, đề xuất endpoint/Sysmon mở rộng.
- Hướng tích hợp **IPS inline bên ngoài**, không nhầm với EVAL.
- Kết luận và kiến nghị.

## Tài liệu tham khảo

Lấy từ [`../docs/09-references.md`](../docs/09-references.md), dẫn nguồn trong từng phần.
