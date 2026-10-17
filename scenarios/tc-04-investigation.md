# TC-04 — Quy trình điều tra event: Alert → Hunt → PCAP → Case

**Mục tiêu:** Demo tính năng quản lý và điều tra sự cố thay vì chỉ hiển thị alert.

1. Từ sự kiện **thực tế** trong Alerts hoặc Hunt, xác định timestamp, src/dst IP, protocol, rule khi có.
2. Pivot sang Hunt, mở rộng khoảng thời gian hợp lý, đối chiếu các event liên quan.
3. Nếu có packet capture cho flow, pivot sang PCAP và giải thích giao thức/đường truyền; không dựng ảnh giả nếu không có PCAP.
4. Tạo Case tương ứng, ghi mô tả, evidence refs, observable, giả thuyết và mức độ chắc chắn.
5. Hoàn thành bảng đánh giá trong `report/results-template.csv`.

## Mẫu kết luận

- **Signal:** loại metadata/alert quan sát được.
- **Context:** phạm vi IP lab, traffic generator, thời điểm.
- **Evidence:** link/đường dẫn ảnh log đã được làm sạch.
- **Finding:** giải thích hành vi phù hợp/không phù hợp với test.
- **Limitations:** phần payload mã hóa hoặc capture không thấy.

**Observed:** _Chưa chạy_  
**Evidence:** _Chưa có_  
**Verdict:** `NOT_RUN`
