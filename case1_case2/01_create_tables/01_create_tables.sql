IF OBJECT_ID('dbo.craddle_ambil', 'U') IS NOT NULL DROP TABLE dbo.craddle_ambil;
IF OBJECT_ID('dbo.craddle_kirim', 'U') IS NOT NULL DROP TABLE dbo.craddle_kirim;
IF OBJECT_ID('dbo.temp_craddle', 'U') IS NOT NULL DROP TABLE dbo.temp_craddle;
IF OBJECT_ID('dbo.report', 'U') IS NOT NULL DROP TABLE dbo.report;

-- Tabel temporary untuk craddle ambil
CREATE TABLE dbo.craddle_ambil (
    tanggal DATETIME,
    customer VARCHAR(225), 
    craddle_ambil VARCHAR(50),
    p_akhir FLOAT
);

-- Tabel temporary untuk craddle kirim
CREATE TABLE dbo.craddle_kirim (
    tanggal DATETIME,
    customer VARCHAR(225), 
    craddle_kirim VARCHAR(50),
    p_awal FLOAT
);

-- Tabel temporary untuk data craddle
CREATE TABLE dbo.temp_craddle (
    tanggal DATETIME,
    customer VARCHAR(225), 
    rc_kirim_1 VARCHAR(50),
    p_kirim_1 FLOAT,
    rc_ambil_1 VARCHAR(50),
    p_ambil_1 FLOAT
);

-- Tabel report untuk hasil akhir
CREATE TABLE dbo.report (
    customer VARCHAR(225),
    craddle VARCHAR(20),
    tgl_kirim DATETIME,
    tgl_ambil DATETIME,
    p_awal FLOAT,
    p_akhir FLOAT,
    buff DATETIME,
    nilai_sm3 FLOAT,
    revenue_idr FLOAT
);
