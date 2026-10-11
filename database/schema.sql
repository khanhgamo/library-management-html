-- =====================================================================
-- VAU DIGITAL LIBRARY - MariaDB schema (XAMPP)
-- DB: vau_library | charset utf8mb4
--
-- Cach chay tren HeidiSQL (khuyen nghi):
--   1. Mo HeidiSQL, tao session: Host 127.0.0.1 - Port 3307 - User root
--      (port 3307 vi 3306 da bi service MySQL/MariaDB khac chiem tren may nay).
--   2. File > Open > chon schema.sql (neu hoi encoding: chon UTF-8).
--   3. Nhan F9 (hoac nut Play xanh) de chay toan bo file.
--      HeidiSQL hieu lenh DELIMITER nen khoi trigger se duoc nap dung.
--   4. Lam tuong tu voi seed.sql de nap du lieu mau.
-- Cach khac: phpMyAdmin > Import, hoac trang ?page=install, hoac CLI:
--   "D:\Xampp\php\php.exe" install_cli.php
-- =====================================================================
CREATE DATABASE IF NOT EXISTS vau_library CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE vau_library;
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------- 1. Người dùng ----------
CREATE TABLE IF NOT EXISTS users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL COMMENT 'MSSV/MGV/Mã NV',
  full_name VARCHAR(120) NOT NULL,
  email VARCHAR(150) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('admin','librarian','lecturer','student') NOT NULL DEFAULT 'student',
  faculty VARCHAR(120) DEFAULT NULL COMMENT 'Khoa/Bộ môn',
  class_name VARCHAR(50) DEFAULT NULL COMMENT 'Lớp (SV)',
  phone VARCHAR(20) DEFAULT NULL,
  status ENUM('active','locked') NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_users_code (code),
  UNIQUE KEY uq_users_email (email),
  KEY ix_users_role (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 2. Danh mục (theo chuyên ngành hàng không) ----------
CREATE TABLE IF NOT EXISTS categories (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  UNIQUE KEY uq_cat_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 3. Sách / Tài liệu số ----------
CREATE TABLE IF NOT EXISTS books (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  isbn VARCHAR(30) DEFAULT NULL,
  authors VARCHAR(255) DEFAULT NULL,
  publisher VARCHAR(150) DEFAULT NULL,
  publish_year SMALLINT DEFAULT NULL,
  category_id INT UNSIGNED DEFAULT NULL,
  doc_type ENUM('physical','ebook','both') NOT NULL DEFAULT 'both' COMMENT 'Vật lý / Số / Cả hai',
  quantity_total INT NOT NULL DEFAULT 1,
  quantity_available INT NOT NULL DEFAULT 1,
  shelf VARCHAR(50) DEFAULT NULL COMMENT 'Vị trí kệ (sách vật lý)',
  price DECIMAL(12,0) DEFAULT 0 COMMENT 'Giá bìa (tính đền mất - BR08)',
  language VARCHAR(20) DEFAULT 'vi',
  pages INT DEFAULT NULL,
  cover_image VARCHAR(255) DEFAULT NULL,
  file_path VARCHAR(255) DEFAULT NULL COMMENT 'Đường dẫn ebook trong uploads/ebooks',
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY ix_books_cat (category_id),
  KEY ix_books_title (title),
  UNIQUE KEY uq_books_isbn (isbn) COMMENT 'ISBN duy nhat (NULL duoc phep lap); giup seed UPSERT luy dang',
  FULLTEXT KEY ft_books (title, authors, description),
  CONSTRAINT fk_books_cat FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 4. Lượt mượn / trả ----------
CREATE TABLE IF NOT EXISTS borrows (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  book_id INT UNSIGNED NOT NULL,
  borrow_date DATE NOT NULL,
  due_date DATE NOT NULL,
  return_date DATE DEFAULT NULL,
  status ENUM('pending','borrowing','overdue','returned','rejected','lost') NOT NULL DEFAULT 'pending',
  approved_by INT UNSIGNED DEFAULT NULL,
  note VARCHAR(255) DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY ix_bor_user (user_id),
  KEY ix_bor_book (book_id),
  KEY ix_bor_status (status),
  CONSTRAINT fk_bor_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_bor_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  CONSTRAINT fk_bor_approver FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 5. Đặt trước (giữ chỗ khi hết sách - BR06) ----------
CREATE TABLE IF NOT EXISTS reservations (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  book_id INT UNSIGNED NOT NULL,
  reserved_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  hold_until DATETIME DEFAULT NULL,
  status ENUM('waiting','ready','expired','cancelled','fulfilled') NOT NULL DEFAULT 'waiting',
  KEY ix_res_user (user_id), KEY ix_res_book (book_id),
  CONSTRAINT fk_res_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_res_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 6. Đánh giá ----------
CREATE TABLE IF NOT EXISTS reviews (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  book_id INT UNSIGNED NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_review (user_id, book_id),
  CONSTRAINT fk_rev_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_rev_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 7. Phạt (BR08) ----------
CREATE TABLE IF NOT EXISTS fines (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  borrow_id INT UNSIGNED NOT NULL,
  user_id INT UNSIGNED NOT NULL,
  amount DECIMAL(12,0) NOT NULL DEFAULT 0,
  reason VARCHAR(255) DEFAULT NULL,
  status ENUM('unpaid','paid') NOT NULL DEFAULT 'unpaid',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  paid_at DATETIME DEFAULT NULL,
  KEY ix_fine_user (user_id),
  CONSTRAINT fk_fine_borrow FOREIGN KEY (borrow_id) REFERENCES borrows(id) ON DELETE CASCADE,
  CONSTRAINT fk_fine_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 8. Thông báo ----------
CREATE TABLE IF NOT EXISTS announcements (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  content TEXT NOT NULL,
  created_by INT UNSIGNED DEFAULT NULL,
  is_pinned TINYINT(1) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_ann_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ---------- 9. Nhật ký tải/đọc ebook ----------
CREATE TABLE IF NOT EXISTS download_logs (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED DEFAULT NULL,
  book_id INT UNSIGNED NOT NULL,
  action ENUM('view','download') NOT NULL DEFAULT 'view',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  KEY ix_dl_book (book_id),
  CONSTRAINT fk_dl_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  CONSTRAINT fk_dl_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================================
-- HƯỚNG B: fines.user_id là DƯ THỪA CÓ CHỦ Ý (denormalization), giữ lại để
-- phục vụ truy vấn nóng BR-05 (sum_unpaid_fines) và thống kê mà không phải
-- JOIN qua borrows mỗi request. Tính đúng đắn (fines.user_id = borrows.user_id
-- của borrow_id tương ứng) do 3 trigger dưới đây bảo vệ ở tầng DB,
-- không còn phụ thuộc hoàn toàn vào code PHP.
-- Kiểm tra định kỳ: php tools/check_consistency.php
-- =====================================================================
ALTER TABLE fines MODIFY COLUMN user_id INT UNSIGNED NOT NULL
  COMMENT 'Du thua co chu y (= borrows.user_id); DB bao ve bang trigger trg_fines_*';

DROP TRIGGER IF EXISTS trg_fines_bi;
DROP TRIGGER IF EXISTS trg_fines_bu;
DROP TRIGGER IF EXISTS trg_borrows_au_sync_fine;

DELIMITER //

CREATE TRIGGER trg_fines_bi BEFORE INSERT ON fines FOR EACH ROW
BEGIN
  DECLARE v_uid INT UNSIGNED;
  SELECT user_id INTO v_uid FROM borrows WHERE id = NEW.borrow_id;
  IF v_uid IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fines: borrow_id khong ton tai';
  ELSEIF NEW.user_id != v_uid THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fines.user_id phai bang borrows.user_id (denormalization co kiem soat)';
  END IF;
END//

CREATE TRIGGER trg_fines_bu BEFORE UPDATE ON fines FOR EACH ROW
BEGIN
  DECLARE v_uid INT UNSIGNED;
  IF NEW.borrow_id != OLD.borrow_id OR NEW.user_id != OLD.user_id THEN
    SELECT user_id INTO v_uid FROM borrows WHERE id = NEW.borrow_id;
    IF v_uid IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fines: borrow_id khong ton tai';
    ELSEIF NEW.user_id != v_uid THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'fines.user_id phai bang borrows.user_id (denormalization co kiem soat)';
    END IF;
  END IF;
END//

CREATE TRIGGER trg_borrows_au_sync_fine AFTER UPDATE ON borrows FOR EACH ROW
BEGIN
  IF NEW.user_id != OLD.user_id THEN
    UPDATE fines SET user_id = NEW.user_id WHERE borrow_id = NEW.id;
  END IF;
END//

DELIMITER ;

SET FOREIGN_KEY_CHECK