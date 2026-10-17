# Contributing

Dự án phục vụ nghiên cứu và học phần. Mọi thay đổi nên có mục tiêu rõ và có nguồn:

1. Tạo issue mô tả hạng mục và test case.
2. Viết tài liệu Markdown ngắn gọn, chỉ rõ phiên bản Security Onion 3 và ngày truy cập nguồn.
3. Không commit secrets, PCAP raw, dump, ảnh chứa dữ liệu thật chưa làm sạch.
4. Đối với phần demo, ghi `NOT_RUN`, `PASS`, `FAIL`, `INCONCLUSIVE` dựa trên evidence thực tế.
5. Chạy `python3 scripts/check_repo.py` trước khi tạo PR.
6. Ghi thay đổi trong `CHANGELOG.md` nếu có tác động tới topology, cấu hình hoặc kết quả nghiên cứu.

Không chạy thử nghiệm trên mạng không thuộc quyền quản lý hoặc không được cấp phép.
