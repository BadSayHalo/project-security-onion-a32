# Security Policy — Academic Lab

## Phạm vi kiểm thử được phép

Chỉ traffic đến những VM tự quản lý trên Internal Network `lab-ids`, ví dụ `192.168.100.10` và `192.168.100.20` khi chúng thực sự thuộc lab. Không quét hệ thống trường học/công ty/bên thứ ba nếu chưa có giấy phép rõ ràng.

## Dữ liệu không được đưa lên GitHub public

- Password, SOC credentials, authentication cookies, API token, keys.
- PCAP thật có thông tin cá nhân; dữ liệu HTTP body, token/session, private DNS, IP công cộng nhạy cảm.
- Full VM images và log lỗi chưa rà soát bí mật.

## Nếu lỡ commit bí mật

Thu hồi/đổi bí mật ngay, xử lý lịch sử Git và báo người chịu trách nhiệm repo. Chỉ xóa file ở commit mới **không loại khỏi lịch sử Git**.

## Lỗ hổng ở bản thân Security Onion

Không báo disclosure vào issue public của đồ án; thực hiện theo [hướng dẫn bảo mật chính thức](https://docs.securityonion.net/en/3/main/security/).
