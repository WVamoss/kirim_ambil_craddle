-- Melihat data dari tabel sumber (t_pengiriman_craddle)
SELECT 
    customer_1, 
    jam_berangkat, 
    rc_kirim_1_customer_1,
    p_kirim_1_customer_1, 
    rc_ambil_1_customer_1,
    p_ambil_1_customer_1 
FROM dbo.t_pengiriman_craddle
ORDER BY jam_berangkat DESC;

-- Melihat semua data tabel t_pengiriman_craddle
SELECT * FROM dbo.t_pengiriman_craddle;

-- Melihat data tabel temporary craddle_ambil
SELECT * FROM dbo.craddle_ambil;

-- Melihat data tabel temporary craddle_kirim
SELECT * FROM dbo.craddle_kirim;

-- Melihat data tabel temporary temp_craddle
SELECT * FROM dbo.temp_craddle;

-- Melihat data tabel report
SELECT * FROM dbo.report;

-- Melihat data master trailer
SELECT * FROM dbo.master_trailer;

-- Melihat data master customer
SELECT * FROM dbo.master_customer;
