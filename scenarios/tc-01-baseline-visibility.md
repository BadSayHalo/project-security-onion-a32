# TC-01 — Kiểm tra khả năng quan sát traffic

**Mục tiêu:** Chứng minh sensor có thể thấy traffic giữa Kali và Ubuntu và metadata được ingest.

**Preconditions:** `so-status` ổn định; Internal Network `lab-ids`; Kali `.10`, Ubuntu `.20`; traffic đi đúng IP lab.

## Thao tác

1. Ubuntu chạy HTTP service đơn giản trên port 8000 để làm test (trong lab):

   ```bash
   python3 -m http.server 8000 --bind 192.168.100.20
   ```

2. Trên Security Onion, `sudo tcpdump -ni <MONITOR_IF> 'host 192.168.100.10 and host 192.168.100.20'`.
3. Kali: `ping -c 4 192.168.100.20` và `curl http://192.168.100.20:8000/`.
4. Truy cập SOC Hunt / Dashboards theo thời gian và IP vừa test.

## Expected (giả thuyết cần xác minh)

- Network hoạt động, tcpdump thấy traffic hai chiều.
- Zeek có metadata kết nối; nếu không thì phân tích ingest/filter.
- Không bắt buộc có Suricata Alert.

**Observed:** _Chưa chạy_  
**Evidence:** _Chưa có_  
**Verdict:** `NOT_RUN`
