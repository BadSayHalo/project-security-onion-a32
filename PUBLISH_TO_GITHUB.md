# Publish / Update GitHub repository

GitHub account được xác nhận khi chuẩn bị bản này: `BadSayHalo`. Tên repo đề xuất: `security-onion-a32-lab`. **File ZIP trong hội thoại chưa đồng nghĩa repository đã tồn tại trên GitHub.**

## Tạo repo mới lần đầu

1. Vào https://github.com/new, Owner `BadSayHalo`, Repository name `security-onion-a32-lab`.
2. Đề xuất đặt **Private** trước khi rà soát ảnh/log. Không chọn tự thêm README, license hay `.gitignore` (repo ZIP đã có).
3. Giải nén ZIP; vào thư mục con `security-onion-a32-lab` rồi mở PowerShell/Git Bash.

```bash
git init -b main
git add .
git commit -m "docs: initialize A32 Security Onion lab and verified setup guide"
git remote add origin https://github.com/BadSayHalo/security-onion-a32-lab.git
git push -u origin main
```

Bạn phải đăng nhập GitHub bằng Credential Manager/browser/PAT hợp lệ khi được hỏi. **Không lưu token trong code hoặc commit.** Nếu push bị 403, kiểm tra tài khoản GitHub và quyền repo; không công khai credential.

## Nếu repo này đã được tạo từ phiên bản cũ

```bash
git clone https://github.com/BadSayHalo/security-onion-a32-lab.git
# Sao chép các file từ ZIP cập nhật vào clone, giữ nguyên .git; kiểm tra các file khác trước khi ghi đè.
git status
git add .
git commit -m "docs: document verified ISO setup, NAT firewall and Windows SSH SOCKS access"
git push origin main
```

**Không `git push --force`** khi repo đã có lịch sử. Nếu bạn sử dụng fork/branch, mở PR để review.

## Trước khi publish public

- [ ] Không có SSH private key, passwords, session cookies, logs, raw PCAP, hostname/IP public hay ảnh chứa tài khoản.
- [ ] `python scripts/check_repo.py` trả OK.
- [ ] Các trạng thái `Verified/Planned` phản ánh bằng chứng thật.
- [ ] README không trình bày chức năng IPS inline chưa triển khai.
- [ ] Source/vendor links và license đã được rà soát.
