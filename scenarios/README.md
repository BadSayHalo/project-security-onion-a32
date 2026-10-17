# Kịch bản kiểm thử trong môi trường cô lập

| Test | File | Điều kiện |
|---|---|---|
| TC-01 | [Baseline visibility](tc-01-baseline-visibility.md) | Bắt buộc, thực hiện đầu tiên |
| TC-02 | [Network reconnaissance](tc-02-port-scan.md) | Chỉ máy lab, mức tải thấp |
| TC-03 | [Web SQL injection](tc-03-web-sqli.md) | Chỉ OWASP Juice Shop, dữ liệu giả |
| TC-04 | [Hunt / PCAP / Case](tc-04-investigation.md) | Cần log / PCAP thực tế |
| TC-05 | [Benign beacon simulation](tc-05-benign-beacon.md) | Tùy chọn, không dùng malware |

Mỗi ca kiểm thử phải có: preconditions, traffic generator, expected, observed (điền sau), timestamp/timezone, screenshots/log paths và kết luận. Không có yêu cầu phải có alert trong mọi test.
