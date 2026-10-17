# TC-02 — Dấu vết quét port/dịch vụ (trong lab)

**Mục tiêu:** Quan sát traffic discovery mức nhẹ từ Kali tới Ubuntu, đối chiếu metadata và alerts khi ruleset khớp.

**Điều kiện:** IP Ubuntu `.20` được xác nhận; có cho phép thực nghiệm; chỉ target này.

```bash
# TRÊN KALI — GIỚI HẠN CHÍNH XÁC HOST VÀ PORT
nmap -sT -Pn -p 22,80,443,8000 --max-rate 5 192.168.100.20
```

Kiểm tra `tcpdump` và Zeek `conn` trong SOC. Xem Alerts và rule SID nếu có; **không** đặt điều kiện tuyệt đối phải xuất hiện signature scan.

| Trường | Ghi nhận sau test |
|---|---|
| Timestamp + timezone | Chưa chạy |
| Scanner/target | 192.168.100.10 → 192.168.100.20 |
| Zeek connection event | Chưa xác minh |
| Suricata alert/SID | Chưa xác minh |
| PCAP | Chưa xác minh |
| Kết luận | NOT_RUN |
