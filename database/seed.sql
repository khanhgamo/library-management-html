-- =====================================================================
-- VAU DIGITAL LIBRARY - Dữ liệu mẫu (seed)
-- Cach chay tren HeidiSQL: mo session 127.0.0.1:3307, File > Open > seed.sql
-- (encoding UTF-8), nhan F9. CHAY SAU schema.sql. Co the chay lap lai
-- nhieu lan (UPSERT luy dang, khong nhan ban du lieu).
-- Tai khoan demo (mat khau chung: 123456):
--   admin      / admin@vau.edu.vn      (Quản trị viên)
--   thuthu     / librarian@vau.edu.vn  (Thủ thư)
--   gv001      / gv001@vau.edu.vn      (Giảng viên)
--   sv001..sv003 (Sinh viên)
-- =====================================================================
USE vau_library;

-- hash của "123456" (PASSWORD_DEFAULT, PHP 8.2)
SET @pw = '$2y$10$J4NciLGjnIc/qiPDelSAquQlEdlyk6iEakf10PW3RKlrMetWpa7d2';

INSERT INTO users (code, full_name, email, password_hash, role, faculty, class_name, phone) VALUES
('admin',   'Quản trị viên VAU',      'admin@vau.edu.vn',     @pw, 'admin',     'Phòng Thư viện', '—', '02838444000'),
('thuthu',  'Nguyễn Thị Thủ Thư',     'librarian@vau.edu.vn', @pw, 'librarian', 'Phòng Thư viện', '—', '02838444001'),
('gv001',   'TS. Trần Văn Giảng',     'gv001@vau.edu.vn',     @pw, 'lecturer',  'Khoa Kỹ thuật Hàng không', '—', '0901000001'),
('sv001',   'Nguyễn Văn An',          'sv001@vaa.edu.vn',     @pw, 'student',   'Khoa Quản lý bay', 'QLB21A', '0901000002'),
('sv002',   'Lê Thị Bình',            'sv002@vaa.edu.vn',     @pw, 'student',   'Khoa Không lưu', 'KLQ22B', '0901000003'),
('sv003',   'Phạm Quốc Cường',        'sv003@vaa.edu.vn',     @pw, 'student',   'Khoa Kỹ thuật Hàng không', 'KTHK21C', '0901000004')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);

INSERT INTO categories (code, name, description) VALUES
('GT-HK',  'Giáo trình Hàng không', 'Giáo trình đào tạo các chuyên ngành hàng không'),
('KT-MB',  'Kỹ thuật Tàu bay', 'Bảo dưỡng, kết cấu, động cơ tàu bay'),
('QL-BAY', 'Quản lý bay & Khai thác', 'Khai thác bay, quản trị hàng không'),
('KL-KL',  'Không lưu (ATC)', 'Kiểm soát không lưu, thông tin liên lạc'),
('AT-HK',  'An toàn & An ninh HK', 'SMS, an toàn khai thác, an ninh'),
('LUAT',   'Luật Hàng không', 'ICAO Annex, luật HKVN, công ước quốc tế'),
('AV-ENG', 'Tiếng Anh Hàng không', 'Aviation English, ICAO Level 4-6'),
('LV-KLTN','Luận văn & NCKH', 'Luận văn tốt nghiệp, đề tài NCKH sinh viên')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- Sách: UPSERT theo ISBN (lũy đẳng khi cài lại). Riêng sách NULL-ISBN (luận văn
-- mẫu) không bắt được UNIQUE nên xóa-trước-thêm-sau theo tiêu đề.
DELETE FROM books WHERE isbn IS NULL AND title LIKE 'Luận văn mẫu:%';

INSERT INTO books (title, isbn, authors, publisher, publish_year, category_id, doc_type, quantity_total, quantity_available, shelf, price, language, pages, description, is_active) VALUES
('Giáo trình Cơ sở Hàng không dân dụng', '978-604-01-0001-1', 'TS. Trần Văn Giảng (chủ biên)', 'NXB Hàng không VN', 2023,
 (SELECT id FROM categories WHERE code='GT-HK'), 'both', 20, 20, 'A1-01', 185000, 'vi', 320, 'Kiến thức nền tảng: lịch sử, tổ chức ICAO/IATA, hãng hàng không, sân bay, tàu bay.', 1),
('Bảo dưỡng và Khai thác Tàu bay A320', '978-604-01-0002-8', 'KS. Lê Bảo Trì; Airbus Training', 'NXB Giao thông', 2022,
 (SELECT id FROM categories WHERE code='KT-MB'), 'both', 10, 10, 'B2-04', 250000, 'vi', 412, 'Hệ thống A320: động cơ, điện - điện tử, thủy lực, quy trình bảo dưỡng line/base.', 1),
('Quản trị Hãng hàng không hiện đại', '978-604-01-0003-5', 'PGS.TS. Nguyễn Quản Trị', 'NXB Kinh tế', 2024,
 (SELECT id FROM categories WHERE code='QL-BAY'), 'ebook', 0, 0, NULL, 0, 'vi', 288, 'Bản số: mô hình kinh doanh LCC/FSC, revenue management, mạng đường bay.', 1),
('Kiểm soát Không lưu căn bản (ATC Basic)', '978-604-01-0004-2', 'Cục Hàng không VN', 'NXB Hàng không VN', 2021,
 (SELECT id FROM categories WHERE code='KL-KL'), 'both', 15, 15, 'C1-02', 195000, 'vi', 350, 'Phân vùng trời, huấn lệnh ATC, phraseology, xử lý tình huống khẩn nguy.', 1),
('Hệ thống Quản lý An toàn (SMS) trong Hàng không', '978-604-01-0005-9', 'ICAO (biên dịch VAU)', 'NXB Hàng không VN', 2023,
 (SELECT id FROM categories WHERE code='AT-HK'), 'both', 12, 12, 'D1-03', 210000, 'vi', 264, 'Doc 9859: 4 trụ cột SMS, phân tích rủi ro, bảo đảm an toàn.', 1),
('Công ước Chicago & Luật Hàng không Việt Nam', '978-604-01-0006-6', 'ThS. Phạm Luật', 'NXB Chính trị QG', 2022,
 (SELECT id FROM categories WHERE code='LUAT'), 'both', 8, 8, 'E1-01', 175000, 'vi', 296, '19 Phụ ước ICAO, Luật HKVN 2006 (sửa đổi), quyền vận chuyển hàng không.', 1),
('Aviation English for Pilots & ATCOs (ICAO L4)', '978-0-00-000007-7', 'Henry Emery; Andy Roberts', 'Oxford', 2020,
 (SELECT id FROM categories WHERE code='AV-ENG'), 'both', 25, 25, 'F1-05', 320000, 'en', 240, 'Tiếng Anh chuẩn ICAO: RT phraseology, plain English, luyện thi Level 4-5.', 1),
('Khí tượng Hàng không ứng dụng', '978-604-01-0008-0', 'TS. Đỗ Khí Tượng', 'NXB KHTN', 2021,
 (SELECT id FROM categories WHERE code='KT-MB'), 'physical', 6, 6, 'B1-02', 160000, 'vi', 220, 'METAR/SPECI/TAF, hiện tượng nguy hiểm, đọc bản đồ thời tiết.', 1),
('Khai thác Sân bay & Dịch vụ mặt đất', '978-604-01-0009-7', 'IATA (biên dịch)', 'NXB Giao thông', 2023,
 (SELECT id FROM categories WHERE code='QL-BAY'), 'both', 10, 10, 'A2-06', 230000, 'vi', 340, 'Quy hoạch sân bay, slot, ground handling, AHM, an ninh soi chiếu.', 1),
('Luận văn mẫu: Tối ưu lịch bay nội địa bằng ML', NULL, 'SV. Nguyễn Văn An (GVHD: TS. Trần Văn Giảng)', 'VAU', 2024,
 (SELECT id FROM categories WHERE code='LV-KLTN'), 'ebook', 0, 0, NULL, 0, 'vi', 96, 'Luận văn tốt nghiệp xuất sắc 2024: dự báo delay, tối ưu lịch bay bằng học máy.', 1),
('Human Factors in Aviation (Yếu tố con người)', '978-0-00-000011-4', 'ICAO Doc 9683', 'ICAO', 2019,
 (SELECT id FROM categories WHERE code='AT-HK'), 'ebook', 0, 0, NULL, 0, 'en', 180, 'Bản số: SHELL model, CRM/MCC, fatigue management.', 1),
('Động cơ Tuabin khí Hàng không', '978-604-01-0012-7', 'PGS.TS. Võ Động Cơ', 'NXB Bách khoa', 2022,
 (SELECT id FROM categories WHERE code='KT-MB'), 'physical', 5, 4, 'B2-01', 265000, 'vi', 380, 'Chu trình Brayton, buồng đốt, turbine, bảo dưỡng động cơ CFM56/V2500.', 1)
ON DUPLICATE KEY UPDATE title=VALUES(title), authors=VALUES(authors), publisher=VALUES(publisher),
  publish_year=VALUES(publish_year), category_id=VALUES(category_id), doc_type=VALUES(doc_type),
  quantity_total=VALUES(quantity_total), quantity_available=VALUES(quantity_available),
  shelf=VALUES(shelf), price=VALUES(price), language=VALUES(language), pages=VALUES(pages),
  description=VALUES(description), is_active=VALUES(is_active);

-- Thông báo: không có bảng nào tham chiếu tới nên xóa-nạp lại cho lũy đẳng.
DELETE FROM announcements;
INSERT INTO announcements (title, content, created_by, is_pinned) VALUES
('Chào mừng đến Thư viện số VAU', 'Hệ thống thư viện số chính thức của Học viện Hàng không Việt Nam đã vận hành. Sinh viên đăng nhập bằng MSSV để mượn sách, đọc ebook và đặt giữ chỗ.\n\nTài khoản demo: sv001 / 123456.', (SELECT id FROM users WHERE code='admin' LIMIT 1), 1),
('Lịch nghỉ lễ & gia hạn tự động', 'Sách đến hạn trong kỳ nghỉ lễ được tự động gia hạn 7 ngày. Phạt quá hạn 5.000đ/ngày/cuốn, vui lòng trả đúng hạn.', (SELECT id FROM users WHERE code='thuthu' LIMIT 1), 0),
('Bổ sung 500+ ebook ICAO/IATA', 'Thư viện vừa số hóa giáo trình ICAO Annex, IATA AHM và luận văn xuất sắc. Mục “Ebook” cho phép đọc online miễn phí trong trường.', (SELECT id FROM users WHERE code='thuthu' LIMIT 1), 0);
