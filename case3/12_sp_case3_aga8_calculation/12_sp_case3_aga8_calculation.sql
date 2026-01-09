IF OBJECT_ID('dbo.sp_case3_aga8_calculation', 'P') IS NOT NULL 
    DROP PROCEDURE dbo.sp_case3_aga8_calculation;
GO

CREATE PROCEDURE sp_case3_aga8_calculation
    @customer VARCHAR(100) = 'PT A1',
    @year_period INT = 2022,
    @month_period TINYINT = 1,
    @period_number TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declare variables
    DECLARE @specific_gravity FLOAT;
    DECLARE @content_co2 FLOAT;
    DECLARE @content_n2 FLOAT;
    DECLARE @heating_value FLOAT;
    DECLARE @base_pressure FLOAT;
    DECLARE @base_temp FLOAT;
    
    -- Ambil Gas Specification dari master
    SELECT 
        @specific_gravity = specific_gravity,
        @content_co2 = content_co2,
        @content_n2 = content_n2,
        @heating_value = heating_value_btu_scf,
        @base_pressure = base_pressure_bar,
        @base_temp = base_temp_celsius
    FROM dbo.m_gas_specification
    WHERE customer = @customer;
    
    -- Validasi jika customer tidak ditemukan
    IF @specific_gravity IS NULL
    BEGIN
        RAISERROR('Customer tidak ditemukan di master gas specification', 16, 1);
        RETURN;
    END
    
    -- Truncate report table
    TRUNCATE TABLE dbo.report_case3_aga8;
    
    -- Insert calculated data ke report table
    INSERT INTO dbo.report_case3_aga8 (
        customer, craddle, year_period, month_period, period_number,
        tgl_kirim, tgl_ambil,
        p_awal_bar, p_akhir_bar, 
        temp_awal_celsius, temp_akhir_celsius, 
        vol_silinder_liter,
        specific_gravity, content_co2, content_n2,
        volume_awal_sm3, volume_akhir_sm3, volume_total_sm3,
        volume_std_mmscf, heating_quantity_mmbtu,
        harga_kontrak_per_sm3, total_revenue_idr
    )
    SELECT 
        r.customer,
        r.craddle,
        @year_period AS year_period,
        @month_period AS month_period,
        @period_number AS period_number,
        r.tgl_kirim,
        r.tgl_ambil,
        r.p_awal AS p_awal_bar,
        r.p_akhir AS p_akhir_bar,
        27.0 AS temp_awal_celsius,      -- Dari data sample: Tk1 = 27°C
        32.0 AS temp_akhir_celsius,     -- Dari data sample: Tk2 = 32°C
        t.lwc AS vol_silinder_liter,
        @specific_gravity AS specific_gravity,
        @content_co2 AS content_co2,
        @content_n2 AS content_n2,
        
        -- FORMULA AGA8 - Volume Awal (SM3)
        -- V = (Vol_Silinder × (P + Pbase) / Pbase) × (Tbase + 273.15) / (T + 273.15)
        CAST(
            (t.lwc * ((r.p_awal + @base_pressure) / @base_pressure)) * 
            ((@base_temp + 273.15) / (27.0 + 273.15))
        AS DECIMAL(18,2)) AS volume_awal_sm3,
        
        -- FORMULA AGA8 - Volume Akhir (SM3)
        CAST(
            (t.lwc * ((r.p_akhir + @base_pressure) / @base_pressure)) * 
            ((@base_temp + 273.15) / (32.0 + 273.15))
        AS DECIMAL(18,2)) AS volume_akhir_sm3,
        
        -- Volume Total (SM3) = Volume Awal - Volume Akhir
        CAST(
            (
                (t.lwc * ((r.p_awal + @base_pressure) / @base_pressure)) * 
                ((@base_temp + 273.15) / (27.0 + 273.15))
            ) - (
                (t.lwc * ((r.p_akhir + @base_pressure) / @base_pressure)) * 
                ((@base_temp + 273.15) / (32.0 + 273.15))
            )
        AS DECIMAL(18,2)) AS volume_total_sm3,
        
        -- Volume Standard (MMSCF) = Volume Total SM3 / 28.3168 / 1000
        -- Konversi: 1 SM3 = 35.3147 SCF, jadi 1 MMSCF = 28316.8 SM3
        CAST(
            (
                (
                    (t.lwc * ((r.p_awal + @base_pressure) / @base_pressure)) * 
                    ((@base_temp + 273.15) / (27.0 + 273.15))
                ) - (
                    (t.lwc * ((r.p_akhir + @base_pressure) / @base_pressure)) * 
                    ((@base_temp + 273.15) / (32.0 + 273.15))
                )
            ) * 0.0353147 / 1000  -- Konversi SM3 ke MMSCF
        AS DECIMAL(18,6)) AS volume_std_mmscf,
        
        -- Heating Quantity (MMBTU) = Volume MMSCF × Heating Value (BTU/SCF)
        CAST(
            (
                (
                    (
                        (t.lwc * ((r.p_awal + @base_pressure) / @base_pressure)) * 
                        ((@base_temp + 273.15) / (27.0 + 273.15))
                    ) - (
                        (t.lwc * ((r.p_akhir + @base_pressure) / @base_pressure)) * 
                        ((@base_temp + 273.15) / (32.0 + 273.15))
                    )
                ) * 0.0353147 / 1000
            ) * @heating_value
        AS DECIMAL(18,2)) AS heating_quantity_mmbtu,
        
        -- Harga kontrak (dari master customer)
        c.rupiah_pjbg AS harga_kontrak_per_sm3,
        
        -- Total Revenue (IDR) = Volume Total SM3 × Harga Kontrak
        CAST(
            (
                (
                    (t.lwc * ((r.p_awal + @base_pressure) / @base_pressure)) * 
                    ((@base_temp + 273.15) / (27.0 + 273.15))
                ) - (
                    (t.lwc * ((r.p_akhir + @base_pressure) / @base_pressure)) * 
                    ((@base_temp + 273.15) / (32.0 + 273.15))
                )
            ) * c.rupiah_pjbg
        AS DECIMAL(18,2)) AS total_revenue_idr
        
    FROM dbo.report r
    INNER JOIN dbo.master_trailer t ON r.craddle = t.nama
    INNER JOIN dbo.master_customer c ON r.customer = c.nama
    WHERE r.customer = @customer;
    
    -- Display hasil
    SELECT 
        customer,
        CAST(tgl_ambil AS DATE) AS Tanggal,
        craddle,
        p_awal_bar AS P_Awal_Bar,
        p_akhir_bar AS P_Akhir_Bar,
        temp_awal_celsius AS Temp_Awal_C,
        temp_akhir_celsius AS Temp_Akhir_C,
        vol_silinder_liter AS Vol_Silinder_Liter,
        
        -- Gas Specification
        specific_gravity AS Specific_Gravity,
        content_co2 AS CO2_Content,
        content_n2 AS N2_Content,
        
        -- Hasil Perhitungan
        volume_awal_sm3 AS Vol_Awal_SM3,
        volume_akhir_sm3 AS Vol_Akhir_SM3,
        volume_total_sm3 AS Vol_Total_SM3,
        volume_std_mmscf AS Vol_Std_MMSCF,
        heating_quantity_mmbtu AS Heating_Quantity_MMBTU,
        
        -- Revenue
        harga_kontrak_per_sm3 AS Harga_Per_SM3,
        total_revenue_idr AS Total_Revenue_IDR
        
    FROM dbo.report_case3_aga8
    ORDER BY tgl_ambil ASC;
    
    PRINT '=== CASE 3 CALCULATION COMPLETED ===';
    PRINT 'Customer: ' + @customer;
    PRINT 'Period: ' + CAST(@year_period AS VARCHAR) + '-' + 
          CAST(@month_period AS VARCHAR) + ' (' + CAST(@period_number AS VARCHAR) + ')';
    PRINT 'Gas Specification:';
    PRINT '  - Specific Gravity: ' + CAST(@specific_gravity AS VARCHAR);
    PRINT '  - CO2 Content: ' + CAST(@content_co2 AS VARCHAR);
    PRINT '  - N2 Content: ' + CAST(@content_n2 AS VARCHAR);
    PRINT '  - Heating Value: ' + CAST(@heating_value AS VARCHAR) + ' BTU/SCF';
END
GO

-- Execute untuk testing
EXEC sp_case3_aga8_calculation 
    @customer = 'PT A1',
    @year_period = 2022,
    @month_period = 1,
    @period_number = 1;

PRINT '';
PRINT '=== CARA PENGGUNAAN ===';
PRINT 'EXEC sp_case3_aga8_calculation @customer = ''PT A1'', @year_period = 2022, @month_period = 1, @period_number = 1;';
