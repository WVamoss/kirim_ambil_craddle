ALTER PROCEDURE dbo.sp_match_craddle
AS
BEGIN
    SET NOCOUNT ON;

    -- Pastikan data terbaru
    EXEC dbo.sp_load_craddle_kirim_ambil;

    TRUNCATE TABLE dbo.report;

    INSERT INTO dbo.report (customer, craddle, tgl_kirim, tgl_ambil, p_awal, p_akhir)
    SELECT 
        A.customer,
        A.craddle_ambil,
        K.tanggal AS tgl_kirim,
        A.tanggal AS tgl_ambil,
        K.p_awal,
        A.p_akhir
    FROM dbo.craddle_ambil A
    CROSS APPLY (
        SELECT TOP 1 
            K.tanggal,
            K.p_awal
        FROM dbo.craddle_kirim K
        WHERE K.craddle_kirim = A.craddle_ambil
          AND K.customer = A.customer
          AND K.tanggal <= A.tanggal
        ORDER BY K.tanggal DESC
    ) K;

    PRINT 'Matching craddle selesai';
END
GO
