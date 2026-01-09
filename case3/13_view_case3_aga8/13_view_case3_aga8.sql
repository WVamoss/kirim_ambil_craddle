IF OBJECT_ID('dbo.vw_report_case3_aga8', 'V') IS NOT NULL 
    DROP VIEW dbo.vw_report_case3_aga8;
GO

CREATE VIEW dbo.vw_report_case3_aga8
AS
SELECT 
    r.customer,
    CAST(r.tgl_ambil AS DATE) AS Tanggal,
    r.craddle,
    r.year_period AS Tahun,
    r.month_period AS Bulan,
    r.period_number AS Period,
    
    -- Input Data
    r.p_awal_bar AS P_Awal_Bar,
    r.p_akhir_bar AS P_Akhir_Bar,
    r.temp_awal_celsius AS Temp_Awal_C,
    r.temp_akhir_celsius AS Temp_Akhir_C,
    r.vol_silinder_liter AS Vol_Silinder_Liter,
    
    -- Gas Specification
    r.specific_gravity AS Specific_Gravity,
    r.content_co2 AS CO2_Content,
    r.content_n2 AS N2_Content,
    
    -- Output Calculation (AGA8 Method)
    r.volume_awal_sm3 AS Vol_Awal_SM3,
    r.volume_akhir_sm3 AS Vol_Akhir_SM3,
    r.volume_total_sm3 AS Vol_Total_SM3,
    r.volume_std_mmscf AS Vol_Std_MMSCF,
    r.heating_quantity_mmbtu AS Heating_Quantity_MMBTU,
    
    -- Revenue
    r.harga_kontrak_per_sm3 AS Harga_Per_SM3,
    r.total_revenue_idr AS Total_Revenue_IDR,
    
    r.created_date AS Tanggal_Dibuat
    
FROM dbo.report_case3_aga8 r;
GO

PRINT '=== VIEW CASE 3 CREATED ===';
PRINT 'View: vw_report_case3_aga8';
PRINT '';
PRINT 'Cara menggunakan:';
PRINT '-- SELECT * FROM vw_report_case3_aga8;';
PRINT '-- SELECT * FROM vw_report_case3_aga8 WHERE customer = ''PT A1'';';
PRINT '-- SELECT * FROM vw_report_case3_aga8 WHERE Tahun = 2022 AND Bulan = 1;';
PRINT '';
PRINT 'Summary per customer:';
PRINT 'SELECT customer, SUM(Vol_Total_SM3) as Total_SM3, SUM(Total_Revenue_IDR) as Total_Revenue';
PRINT 'FROM vw_report_case3_aga8 GROUP BY customer;';
