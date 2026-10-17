# 05 — Demo runbook (10–15 phút)

> Các bước dưới đây là **kịch bản dự kiến**, chưa có số liệu thực nghiệm. Thực hiện trên các máy trong `lab-ids` thuộc quyền quản lý của nhóm.

## Chuẩn bị trước buổi demo

- [ ] SOC HTTPS mở được từ Host, `so-status` hoạt động.
- [ ] Kali / Ubuntu ping được nhau ở IP lab.
- [ ] NIC Monitor quan sát traffic qua `tcpdump`.
- [ ] Đồng bộ/ghi rõ múi giờ của các máy; chuẩn bị ảnh dự phòng từ **thực nghiệm thực tế**, không làm giả ảnh.
- [ ] Kích hoạt ruleset phù hợp (nếu demo Alert), ghi rõ SID/version của signature.
- [ ] Dự phòng phương án demo offline bằng **PCAP thử nghiệm công khai hợp pháp**, đối chiếu thời điểm PCAP gốc.

## Kịch bản trình diễn

| Mốc | Hoạt động | Kết quả trình bày |
|---|---|---|
| 0:00–2:00 | Giới thiệu topology và phần cứng | Management/Monitor và lý do chọn EVAL |
| 2:00–4:00 | Ping/HTTP và capture bằng tcpdump | Evidence sensor thấy traffic |
| 4:00–6:00 | Truy cập Dashboards / Hunt | Metadata và IP nguồn/đích |
| 6:00–9:00 | Thử TC-02/03; mở Alerts nếu có signature khớp | Alert + lý giải trường hợp **không** xuất hiện alert |
| 9:00–11:00 | Pivot sang PCAP | Phân tích gói tin/protocol nếu có PCAP |
| 11:00–13:00 | Mở Cases, thêm evidence | Liên kết case với event/observable |
| 13:00–15:00 | Kết luận & hướng mở rộng IPS | Hạn chế của EVAL/IDS, Community vs Pro |

## Nguyên tắc đánh giá

- Alert có thể không sinh khi chỉ ping hoặc nmap: đó là một kết quả cần phân tích, không phải lý do tự điền “đạt”.
- HTTP request trong lab giúp quan sát payload; với HTTPS sensor bình thường không đọc được phần payload mã hóa.
- Nếu không có PCAP thật từ test, **không** gắn ảnh giả vào demo.
- Logstash không chạy trong EVAL theo thiết kế, không xem container Logstash thiếu là lỗi sức khỏe khi EVAL hoạt động bình thường.

## Mẫu kết luận cuối demo

> Hệ thống đạt/chưa đạt khả năng quan sát lưu lượng trên NIC Monitor; có/không có metadata Zeek; có/không có cảnh báo Suricata tương ứng quy tắc đã kích hoạt; có/không có PCAP và sự kiện Cases. Phạm vi đề tài là NIDS/NSM thụ động; tính năng IPS inline không được triển khai trong giai đoạn 1.

Chi tiết test tại [`../scenarios/`](../scenarios/) và CSV tại [`../report/results-template.csv`](../report/results-template.csv).
