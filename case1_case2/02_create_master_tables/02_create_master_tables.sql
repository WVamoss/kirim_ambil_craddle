IF OBJECT_ID('dbo.master_trailer', 'U') IS NOT NULL DROP TABLE dbo.master_trailer;
IF OBJECT_ID('dbo.master_customer', 'U') IS NOT NULL DROP TABLE dbo.master_customer;

-- Tabel Master Trailer (untuk LWC/kapasitas trailer)
CREATE TABLE dbo.master_trailer (
    nama NVARCHAR(50), 
    lwc FLOAT -- Liquid Water Capacity
);

-- Insert data dummy Master Trailer
INSERT INTO dbo.master_trailer (nama, lwc)
VALUES 
    ('RC - 11', 10), 
    ('RC - 46', 10), 
    ('RC - 21', 10), 
    ('RC - 34', 10);

-- Tabel Master Customer (untuk harga kontrak)
CREATE TABLE dbo.master_customer (
    nama NVARCHAR(100), 
    rupiah_pjbg FLOAT -- Harga per SM3
);

-- Insert data dummy Master Customer
INSERT INTO dbo.master_customer (nama, rupiah_pjbg) 
VALUES 
    ('PT A', 9000), 
    ('PT B', 10000), 
    ('PT C', 6890), 
    ('PT D', 8500);
