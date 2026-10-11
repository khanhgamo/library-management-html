# ✈ Thư viện số VAU — Bản HTML + CSS tĩnh (giữ SQL)

> Triển khai lại từ `library-management/` (PHP) sang **HTML + CSS thuần túy**, giữ nguyên **SQL**.

## 1. Cách mở (không cần XAMPP, không cần PHP/MySQL)

- Mở file: `D:\PhanMem\XAMPP\htdocs\library-management-html\index.html`
  - Nhấp đúp file, hoặc
  - Truy cập: `http://localhost/library-management-html/` (nếu Apache đang chạy)
- Mọi liên kết đã chuyển từ `?page=xxx` sang file tĩnh:

| Bản PHP (`library-management/`) | Bản HTML tĩnh (thư mục này) |
|---|---|
| `?page=home` | `index.html` |
| `?page=catalog` | `catalog.html` (có lọc client-side theo `?q=`) |
| `?page=book_detail&id=` | `book-detail.html` |
| `?page=ebooks` | `ebooks.html` |
| `?page=reader&id=` | `reader.html` (khung đọc demo) |
| `?page=login` / `register` | `login.html` / `register.html` |
| `?page=dashboard` / `profile` | `dashboard.html` / `profile.html` |
| `?page=announcements` (+detail) | `announcements.html` / `announcement-detail.html` |
| `?page=admin` | `admin.html` (8 KPI demo) |
| `?page=manage_books` / `book_form` | `manage-books.html` / `book-form.html` |
| `?page=manage_categories` | `manage-categories.html` |
| `?page=manage_borrows` | `manage-borrows.html` |
| `?page=manage_fines` (+reservations) | `manage-fines.html` |
| `?page=manage_users` | `manage-users.html` |
| `?page=manage_announcements` | `manage-announcements.html` |
| `config.php / db.php / helpers.php / pages/*.php` | **Đã loại bỏ** (logic demo bằng dữ liệu cứng + `assets/app.js` nhỏ) |
| `database/schema.sql + seed.sql` | **Giữ nguyên** trong `database/` |
| `assets/style.css` | **Giữ nguyên 100%** (giao diện giống hệt bản PHP) |

## 2. Cấu trúc thư mục mới

```
library-management-html/
├── index.html, catalog.html, book-detail.html
├── ebooks.html, reader.html
├── login.html, register.html
├── dashboard.html, profile.html
├── announcements.html, announcement-detail.html
├── admin.html
├── manage-books.html, book-form.html, manage-categories.html
├── manage-borrows.html, manage-fines.html
├── manage-users.html, manage-announcements.html
├── assets/style.css   (copy từ bản PHP)
├── assets/app.js      (bản tĩnh: confirm + tự ẩn alert + lọc ?q=)
└── database/
    ├── schema.sql     (GIỮ NGUYÊN - 9 bảng + 3 trigger)
    └── seed.sql       (ĐỒNG BỘ DB thật - 6 user / 3 danh mục / 15 sách kèm bìa + file DOCX / 3 tin)
```

## 3. SQL được giữ lại — cách dùng khi cần backend thật

1. Tạo DB `vau_library` (utf8mb4), import theo thứ tự:
   - `database/schema.sql` (tạo 9 bảng: users, categories, books, borrows, reservations, reviews, fines, announcements, download_logs + 3 trigger `trg_fines_*`)
   - `database/seed.sql` (tài khoản demo, mật khẩu chung `123456`: `admin`, `thuthu`, `gv001`, `sv001/sv002/sv003`)
2. Dữ liệu cứng trong các file `.html` được lấy đúng từ DB thật (15 sách folder `book/` + ảnh bìa `assets/covers/`).
3. Muốn chạy động trở lại: copy 2 file SQL này về bản PHP hoặc dùng với backend bất kỳ (Node/Python/PHP) — schema không đổi.

## 4. Giới hạn của bản tĩnh (so với bản PHP)

- Form **không ghi DB**: nút "Yêu cầu mượn / Duyệt / Thu tiền / Thêm sách..." chỉ minh họa giao diện hoặc chuyển trang demo.
- Sách **"Xem trước"** (Đắc nhân tâm, 7 thói quen, Thay đổi tí hon, Khởi nghiệp tinh gọn, Truyện Kiều): trang `reader.html` demo đọc thử 2 trang đầu, không có nút tải full (bản PHP cấm tải thật ở server).
- Đăng nhập **không xác thực**: `login.html → dashboard.html` là chuyển trang demo; phân quyền BR-02/BR-09 chỉ thể hiện bằng menu.
- Tìm kiếm `catalog.html?q=` lọc client-side bằng JS (thay cho `LIKE` SQL); phân trang là tĩnh.
- Khung đọc `reader.html` là placeholder — bản PHP mới nhúng `<iframe src="uploads/ebooks/...">` + ghi `download_logs` (BR-07).
- Nghiệp vụ BR-03..BR-10 (hạn mức, phạt 5.000đ/ngày, đền 200%, giữ chỗ 48h) được **hiển thị bằng chữ + số liệu mẫu**, không enforce thật khi thiếu backend.

## 5. Quy ước nghiệp vụ vẫn hiển thị đúng

- BR-04: SV 5 cuốn/14 ngày, GV 10 cuốn/30 ngày (footer + dashboard + admin).
- BR-05: chặn mượn khi còn phạt/quá hạn (alert demo ở `dashboard.html`).
- BR-08: phạt 5.000đ/ngày/cuốn, mất đền 200% (admin + manage-fines + manage-borrows).
- BR-06: giữ chỗ 48h (dashboard + manage-fines).
- BR-10: cấm xóa sách còn mượn active / danh mục còn sách (ghi chú ở manage-books + manage-categories).
