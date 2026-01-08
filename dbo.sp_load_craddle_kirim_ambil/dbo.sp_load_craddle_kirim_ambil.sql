CREATE PROCEDURE dbo.sp_load_craddle_kirim_ambil
AS
BEGIN
    SET NOCOUNT ON;

    TRUNCATE TABLE dbo.craddle_kirim;
    TRUNCATE TABLE dbo.craddle_ambil;

    -- Insert data kirim
    INSERT INTO dbo.craddle_kirim (tanggal, customer, craddle_kirim, p_awal)
    SELECT 
        jam_berangkat,
        customer_1,
        rc_kirim_1_customer_1,
        p_kirim_1_customer_1
    FROM dbo.t_pengiriman_craddle
    WHERE rc_kirim_1_customer_1 IS NOT NULL;

    -- Insert data ambil
    INSERT INTO dbo.craddle_ambil (tanggal, customer, craddle_ambil, p_akhir)
    SELECT 
        jam_berangkat,
        customer_1,
        rc_ambil_1_customer_1,
        p_ambil_1_customer_1
    FROM dbo.t_pengiriman_craddle
    WHERE rc_ambil_1_customer_1 IS NOT NULL;

    PRINT 'Load data kirim & ambil berhasil';
END
GO
