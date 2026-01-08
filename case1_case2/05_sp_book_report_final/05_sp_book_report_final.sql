IF OBJECT_ID('dbo.sp_bookreport', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_bookreport;
GO

CREATE PROCEDURE sp_bookreport
AS
BEGIN
    -- Jalankan SP untuk matching data craddle
    EXEC sp_mencocokkandatacraddle;
    
    -- Generate laporan final
    SELECT 
        r.customer,
        CAST(r.tgl_ambil AS DATE) AS Tanggal,
        r.craddle,
        r.p_awal AS P_Kirim,
        r.p_akhir AS P_Ambil,
        
        -- Step 3: Konversi dari Bar ke SM3
        -- Formula: LWC × [(P_Kirim+1.013)/1.013 × 288.15/(T_Awal+273.15) - (P_Ambil+1.013)/1.013 × 288.15/(T_Akhir+273.15)]
        -- T_Awal = 27°C, T_Akhir = 32°C
        CAST(
            t.lwc * (
                ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) - 
                ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
            ) AS DECIMAL(18,2)
        ) AS Nilai_SM3,
        
        -- Step 4: Ambil Harga Kontrak dari Master Customer
        c.rupiah_pjbg AS Harga_Kontrak_Per_SM3,
        
        -- Step 5: Hitung Total Revenue (SM3 × Harga Kontrak)
        CAST(
            (t.lwc * (
                ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) - 
                ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
            )) * c.rupiah_pjbg 
        AS DECIMAL(18,2)) AS Total_Revenue_IDR
        
    FROM dbo.report r
    INNER JOIN dbo.master_trailer t ON r.craddle = t.nama      -- Relasi Master Trailer (LWC)
    INNER JOIN dbo.master_customer c ON r.customer = c.nama    -- Relasi Master Customer (Harga)
    ORDER BY Tanggal ASC;
END
GO
