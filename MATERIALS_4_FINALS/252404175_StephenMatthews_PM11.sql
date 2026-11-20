-- 6. DDL MYSQL

-- Kode 1: Membuat database
DROP DATABASE IF EXISTS db_sertifikat_perjalanan;
CREATE DATABASE db_sertifikat_perjalanan;
USE db_sertifikat_perjalanan;

-- Kode 2: Tabel Orang
CREATE TABLE Orang (
    id_orang INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    nomor_telepon VARCHAR(25) NOT NULL
) ENGINE=InnoDB;

-- Kode 3: Tabel Tipe
CREATE TABLE Tipe (
    id_tipe INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_tipe VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

-- Kode 4: Tabel Lokasi
CREATE TABLE Lokasi (
    id_lokasi INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_lokasi VARCHAR(120) NOT NULL,
    alamat VARCHAR(255) NOT NULL,
    kota VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Kode 5: Tabel Sertifikat
CREATE TABLE Sertifikat (
    id_sertifikat INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_orang INT UNSIGNED NOT NULL UNIQUE,
    id_tipe INT UNSIGNED NOT NULL,
    tanggal_terbit DATE NOT NULL,
    CONSTRAINT fk_sertifikat_orang
        FOREIGN KEY (id_orang) REFERENCES Orang(id_orang)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_sertifikat_tipe
        FOREIGN KEY (id_tipe) REFERENCES Tipe(id_tipe)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- Kode 6: Tabel Travel_Log
CREATE TABLE Travel_Log (
    id_travel INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_orang INT UNSIGNED NOT NULL,
    id_lokasi INT UNSIGNED NOT NULL,
    waktu_keberangkatan DATETIME NOT NULL,
    waktu_kedatangan DATETIME NULL,
    CONSTRAINT chk_waktu_perjalanan
        CHECK (
            waktu_kedatangan IS NULL
            OR waktu_keberangkatan < waktu_kedatangan
        ),
    CONSTRAINT fk_travel_orang
        FOREIGN KEY (id_orang) REFERENCES Orang(id_orang)
        ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_travel_lokasi
        FOREIGN KEY (id_lokasi) REFERENCES Lokasi(id_lokasi)
        ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 7. DML MYSQL: DATA CONTOH DAN UJI QUERY MANUAL

-- Kode 7: Data Tipe dan Lokasi
INSERT INTO Tipe (nama_tipe) VALUES
('Sertifikat Mobil'),
('Sertifikat Truk');

INSERT INTO Lokasi (nama_lokasi, alamat, kota) VALUES
('Gedung A', 'Jl. Merdeka 10', 'Jakarta'),
('Gedung B', 'Jl. Sudirman 20', 'Jakarta'),
('Gedung C', 'Jl. Asia Afrika 30', 'Bandung');

SELECT * FROM Tipe;
SELECT * FROM Lokasi;

-- Kode 8: Pendaftaran Orang dan Sertifikat
START TRANSACTION;
INSERT INTO Orang (nama, nomor_telepon)
VALUES ('Andi', '0811111111');
SET @andi = LAST_INSERT_ID();
INSERT INTO Sertifikat (id_orang, id_tipe, tanggal_terbit)
VALUES (@andi, 1, '2026-01-01');
COMMIT;

START TRANSACTION;
INSERT INTO Orang (nama, nomor_telepon)
VALUES ('Budi', '0822222222');
SET @budi = LAST_INSERT_ID();
INSERT INTO Sertifikat (id_orang, id_tipe, tanggal_terbit)
VALUES (@budi, 2, '2026-02-01');
COMMIT;

START TRANSACTION;
INSERT INTO Orang (nama, nomor_telepon)
VALUES ('Citra', '0833333333');
SET @citra = LAST_INSERT_ID();
INSERT INTO Sertifikat (id_orang, id_tipe, tanggal_terbit)
VALUES (@citra, 1, '2026-03-01');
COMMIT;

SELECT * FROM Orang;
SELECT * FROM Sertifikat;

-- Kode 9: Pencatatan Perjalanan
INSERT INTO Travel_Log
(id_orang, id_lokasi, waktu_keberangkatan, waktu_kedatangan)
VALUES
(@andi, 1, '2026-11-01 08:00:00', '2026-11-01 09:00:00'),
(@andi, 2, '2026-11-02 10:00:00', '2026-11-02 11:00:00'),
(@budi, 1, '2026-11-03 08:30:00', '2026-11-03 09:30:00'),
(@andi, 1, '2026-11-04 13:00:00', NULL);

SELECT
    id_travel,
    id_orang,
    id_lokasi,
    DATE_FORMAT(waktu_keberangkatan, '%Y-%m-%d %H:%i:%s') AS waktu_keberangkatan,
    DATE_FORMAT(waktu_kedatangan, '%Y-%m-%d %H:%i:%s') AS waktu_kedatangan
FROM Travel_Log
ORDER BY id_travel;

-- Uji 1: Relasi Orang-Sertifikat (1:1)
SELECT
    o.id_orang,
    o.nama,
    s.id_sertifikat,
    t.nama_tipe
FROM Orang AS o
LEFT JOIN Sertifikat AS s
    ON s.id_orang = o.id_orang
LEFT JOIN Tipe AS t
    ON t.id_tipe = s.id_tipe
ORDER BY o.id_orang;

-- Uji 2: Relasi Tipe-Sertifikat (1:N)
SELECT
    t.nama_tipe,
    COUNT(s.id_sertifikat) AS jumlah_sertifikat
FROM Tipe AS t
LEFT JOIN Sertifikat AS s
    ON s.id_tipe = t.id_tipe
GROUP BY t.id_tipe, t.nama_tipe;

-- Uji 3: Relasi Orang-Lokasi (M:N)
SELECT
    o.id_orang,
    o.nama,
    t.nama_tipe,
    l.nama_lokasi,
    DATE_FORMAT(tl.waktu_keberangkatan, '%Y-%m-%d %H:%i:%s') AS waktu_keberangkatan,
    DATE_FORMAT(tl.waktu_kedatangan, '%Y-%m-%d %H:%i:%s') AS waktu_kedatangan
FROM Travel_Log AS tl
JOIN Orang AS o
    ON tl.id_orang = o.id_orang
JOIN Sertifikat AS s
    ON s.id_orang = o.id_orang
JOIN Tipe AS t
    ON t.id_tipe = s.id_tipe
JOIN Lokasi AS l
    ON l.id_lokasi = tl.id_lokasi
ORDER BY o.id_orang, tl.id_travel;

-- Uji 4: Perjalanan berulang
SELECT
    o.nama,
    l.nama_lokasi,
    COUNT(tl.id_travel) AS jumlah_perjalanan
FROM Travel_Log AS tl
JOIN Orang AS o
    ON o.id_orang = tl.id_orang
JOIN Lokasi AS l
    ON l.id_lokasi = tl.id_lokasi
GROUP BY o.id_orang, o.nama, l.id_lokasi, l.nama_lokasi
HAVING COUNT(tl.id_travel) > 1
ORDER BY jumlah_perjalanan DESC;

-- Uji 5: Struktur constraint
SHOW CREATE TABLE Sertifikat;
SHOW CREATE TABLE Travel_Log;

-- Uji 6: Jumlah perjalanan berdasarkan lokasi
SELECT
    l.nama_lokasi,
    COUNT(tl.id_travel) AS jumlah_kunjungan
FROM Lokasi AS l
LEFT JOIN Travel_Log AS tl
    ON tl.id_lokasi = l.id_lokasi
GROUP BY l.id_lokasi, l.nama_lokasi;
