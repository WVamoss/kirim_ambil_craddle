IF OBJECT_ID('dbo.sp_mencocokkandatacraddle', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_mencocokkandatacraddle;
GO

CREATE PROCEDURE sp_mencocokkandatacraddle
AS
BEGIN
    -- Jalankan SP untuk memperbarui data temporary
    EXEC sp_inserttemptabel;
    
    -- Kosongkan tabel report
    TRUNCATE TABLE dbo.report;
    
    -- Insert data hasil matching ke tabel report
    -- Logic: Untuk setiap craddle yang diambil, cari data kirim terdekat sebelumnya
    INSERT INTO dbo.report (customer, craddle, tgl_kirim, tgl_ambil, p_awal, p_akhir)
    SELECT 
        A.customer,
        A.craddle_ambil AS craddle,
        K.tanggal AS tgl_kirim,
        A.tanggal AS tgl_ambil,
        K.p_awal,  -- Tekanan saat kirim (P_Kirim)
        A.p_akhir  -- Tekanan saat diambil (P_Ambil)
    FROM dbo.craddle_ambil A
    CROSS APPLY (
        -- Subquery: Cari 1 data kirim dengan RC sama, customer sama,
        -- dan tanggal paling dekat sebelum tanggal ambil
        SELECT TOP 1 K.tanggal, K.p_awal
        FROM dbo.craddle_kirim K
        WHERE K.craddle_kirim = A.craddle_ambil
          AND K.customer = A.customer
          AND K.tanggal <= A.tanggal
        ORDER BY K.tanggal DESC
    ) K;
    
    -- Tampilkan hasil dengan perhitungan P_Akhir (Tekanan Akhir)
    SELECT 
        customer, 
        craddle, 
        tgl_kirim, 
        tgl_ambil, 
        p_awal AS P_Kirim, 
        p_akhir AS P_Ambil,
        (p_awal - p_akhir) AS Tekanan_Akhir_Bar  -- Step 2: P_Kirim - P_Ambil
    FROM dbo.report
    ORDER BY tgl_ambil ASC;  -- Step 1: Urutkan berdasarkan tanggal
END
GO
