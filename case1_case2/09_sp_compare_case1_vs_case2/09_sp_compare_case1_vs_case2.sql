IF OBJECT_ID('dbo.sp_compare_case1_vs_case2', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_compare_case1_vs_case2;
GO

CREATE PROCEDURE sp_compare_case1_vs_case2
AS
BEGIN
    -- Jalankan SP untuk matching data craddle
    EXEC sp_mencocokkandatacraddle;
    
    -- Generate laporan perbandingan
    SELECT 
        r.customer,
        CAST(r.tgl_ambil AS DATE) AS Tanggal,
        r.craddle,
        r.p_awal AS P_Kirim_Bar,
        r.p_akhir AS P_Ambil_Bar,
        
        -- === CASE 1: (P_Kirim - P_Ambil) LALU dikonversi ke SM3 ===
        (r.p_awal - r.p_akhir) AS Selisih_Bar,
        CAST(
            t.lwc * (
                ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) - 
                ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
            ) AS DECIMAL(18,2)
        ) AS Case1_Hasil_SM3,
        
        -- === CASE 2: Konversi dulu BARU dikurangi ===
        CAST(
            t.lwc * (((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))))
        AS DECIMAL(18,2)) AS Case2_SM3_Kirim,
        
        CAST(
            t.lwc * (((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15))))
        AS DECIMAL(18,2)) AS Case2_SM3_Ambil,
        
        CAST(
            (t.lwc * (((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))))) -
            (t.lwc * (((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))))
        AS DECIMAL(18,2)) AS Case2_Hasil_SM3,
        
        -- === SELISIH HASIL Case 1 vs Case 2 ===
        CAST(
            ABS(
                (t.lwc * (
                    ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) - 
                    ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
                )) -
                (
                    (t.lwc * (((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))))) -
                    (t.lwc * (((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))))
                )
            ) AS DECIMAL(18,4)
        ) AS Selisih_SM3,
        
        -- === REVENUE COMPARISON ===
        CAST(
            (t.lwc * (
                ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) - 
                ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
            )) * c.rupiah_pjbg 
        AS DECIMAL(18,2)) AS Case1_Revenue_IDR,
        
        CAST(
            (
                (t.lwc * (((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))))) -
                (t.lwc * (((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))))
            ) * c.rupiah_pjbg 
        AS DECIMAL(18,2)) AS Case2_Revenue_IDR,
        
        CAST(
            ABS(
                (
                    (t.lwc * (
                        ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) - 
                        ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
                    )) * c.rupiah_pjbg
                ) -
                (
                    (
                        (t.lwc * (((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))))) -
                        (t.lwc * (((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))))
                    ) * c.rupiah_pjbg
                )
            ) AS DECIMAL(18,2)
        ) AS Selisih_Revenue_IDR
        
    FROM dbo.report r
    INNER JOIN dbo.master_trailer t ON r.craddle = t.nama      
    INNER JOIN dbo.master_customer c ON r.customer = c.nama    
    ORDER BY Tanggal ASC;
END
GO

-- Execute untuk melihat perbandingan
EXEC sp_compare_case1_vs_case2;

PRINT '=== PERBANDINGAN CASE 1 vs CASE 2 ===';
PRINT 'Case 1: (P_Kirim - P_Ambil) dalam Bar → Konversi ke SM3';
PRINT 'Case 2: P_Kirim → SM3, P_Ambil → SM3, lalu SM3_Kirim - SM3_Ambil';
PRINT 'Lihat kolom Selisih_SM3 dan Selisih_Revenue_IDR untuk melihat perbedaannya';
