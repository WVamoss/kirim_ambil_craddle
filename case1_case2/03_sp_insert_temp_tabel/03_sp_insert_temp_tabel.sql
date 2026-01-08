IF OBJECT_ID('dbo.sp_inserttemptabel', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_inserttemptabel;
GO

CREATE PROCEDURE sp_inserttemptabel
AS
BEGIN
    -- Kosongkan tabel temporary terlebih dahulu
    TRUNCATE TABLE dbo.craddle_kirim;
    TRUNCATE TABLE dbo.craddle_ambil;
    
    -- Insert data craddle yang dikirim (P_Kirim)
    INSERT INTO dbo.craddle_kirim (tanggal, customer, craddle_kirim, p_awal)
    SELECT 
        jam_berangkat, 
        customer_1, 
        rc_kirim_1_customer_1, 
        p_kirim_1_customer_1
    FROM dbo.t_pengiriman_craddle
    WHERE rc_kirim_1_customer_1 IS NOT NULL;
    
    -- Insert data craddle yang diambil (P_Ambil)
    INSERT INTO dbo.craddle_ambil (tanggal, customer, craddle_ambil, p_akhir)
    SELECT 
        jam_berangkat, 
        customer_1, 
        rc_ambil_1_customer_1, 
        p_ambil_1_customer_1
    FROM dbo.t_pengiriman_craddle
    WHERE rc_ambil_1_customer_1 IS NOT NULL;
    
END
GO
