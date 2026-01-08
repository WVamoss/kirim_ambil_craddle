IF OBJECT_ID('dbo.sp_bookreport_case2', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_bookreport_case2;
GO

CREATE PROCEDURE sp_bookreport_case2
AS
BEGIN
    -- Jalankan SP untuk matching data craddle
    EXEC sp_mencocokkandatacraddle;
    
    -- Generate laporan Case 2
    SELECT 
        r.customer,
        CAST(r.tgl_ambil AS DATE) AS Tanggal,
        r.craddle,
        r.p_awal AS P_Kirim_Bar,
        r.p_akhir AS P_Ambil_Bar,
        
        -- CASE 2: Konversi P_Kirim ke SM3 terlebih dahulu (Misal A)
        CAST(
            t.lwc * (
                ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15)))
            ) AS DECIMAL(18,2)
        ) AS Hasil_Konversi_SM3_P_Kirim,
        
        -- CASE 2: Konversi P_Ambil ke SM3 terlebih dahulu (Misal B)
        CAST(
            t.lwc * (
                ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
            ) AS DECIMAL(18,2)
        ) AS Hasil_Konversi_SM3_P_Ambil,
        
        -- CASE 2: Hasil Akhir = A - B (SM3 P_Kirim - SM3 P_Ambil)
        CAST(
            (t.lwc * (((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))))) -
            (t.lwc * (((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))))
        AS DECIMAL(18,2)) AS Hasil_Konversi_Akhir_SM3,
        
        -- Harga Kontrak dari Master Customer
        c.rupiah_pjbg AS Harga_Kontrak_Per_SM3,
        
        -- Total Revenue (Hasil Akhir SM3 × Harga Kontrak)
        CAST(
            (
                (t.lwc * (((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))))) -
                (t.lwc * (((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))))
            ) * c.rupiah_pjbg 
        AS DECIMAL(18,2)) AS Total_Revenue_IDR
        
    FROM dbo.report r
    INNER JOIN dbo.master_trailer t ON r.craddle = t.nama      
    INNER JOIN dbo.master_customer c ON r.customer = c.nama    
    ORDER BY Tanggal ASC;
END
GO

-- Execute untuk melihat hasil
EXEC sp_bookreport_case2;

PRINT 'Case 2 Report berhasil dibuat!';
PRINT 'Metode: Konversi SM3 dilakukan SEBELUM pengurangan';
PRINT 'Formula: SM3_Kirim - SM3_Ambil = Hasil_Akhir_SM3';
