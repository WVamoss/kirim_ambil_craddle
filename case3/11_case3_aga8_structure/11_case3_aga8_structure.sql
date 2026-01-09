IF OBJECT_ID('dbo.m_gas_specification', 'U') IS NOT NULL 
    DROP TABLE dbo.m_gas_specification;

CREATE TABLE dbo.m_gas_specification (
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer VARCHAR(100),
    specific_gravity FLOAT,          -- Specific Gravity (0.5841)
    content_co2 FLOAT,                -- Content of CO2 (0.8477)
    content_n2 FLOAT,                 -- Content of N2 (0.7632)
    heating_value_btu_scf FLOAT,      -- Heating Value BTU/SCF (1139.37595)
    base_pressure_bar FLOAT DEFAULT 1.013258,  -- Base Pressure (1.013258 Bar)
    base_temp_celsius FLOAT DEFAULT 30.00,     -- Base Temperature (30°C)
    created_date DATETIME DEFAULT GETDATE()
);

-- Insert sample data
INSERT INTO dbo.m_gas_specification 
    (customer, specific_gravity, content_co2, content_n2, heating_value_btu_scf)
VALUES 
    ('PT A1', 0.5841, 0.8477, 0.7632, 1139.37595),
    ('PT A', 0.5841, 0.8477, 0.7632, 1139.37595),
    ('PT B', 0.5900, 0.8500, 0.7700, 1150.00000),
    ('PT C', 0.5750, 0.8400, 0.7600, 1130.00000);

-- ============================================
-- TABEL: REPORT CASE 3 (AGA8)
-- ============================================
IF OBJECT_ID('dbo.report_case3_aga8', 'U') IS NOT NULL 
    DROP TABLE dbo.report_case3_aga8;

CREATE TABLE dbo.report_case3_aga8 (
    id INT IDENTITY(1,1) PRIMARY KEY,
    customer VARCHAR(100),
    craddle VARCHAR(20),
    year_period INT,
    month_period TINYINT,
    period_number TINYINT,
    
    -- Data Transaksi
    tgl_kirim DATETIME,
    tgl_ambil DATETIME,
    
    -- Pressure & Temperature (Input)
    p_awal_bar FLOAT,                 -- Pressure awal (Bar)
    p_akhir_bar FLOAT,                -- Pressure akhir (Bar)
    temp_awal_celsius FLOAT,          -- Temperature awal (°C)
    temp_akhir_celsius FLOAT,         -- Temperature akhir (°C)
    vol_silinder_liter FLOAT,         -- Volume silinder (Liter)
    
    -- Gas Specification (dari master)
    specific_gravity FLOAT,
    content_co2 FLOAT,
    content_n2 FLOAT,
    
    -- Hasil Perhitungan AGA8
    volume_awal_sm3 FLOAT,            -- Volume awal dalam SM3 (1 atm, base temp)
    volume_akhir_sm3 FLOAT,           -- Volume akhir dalam SM3
    volume_total_sm3 FLOAT,           -- Volume total pemakaian (SM3)
    volume_std_mmscf FLOAT,           -- Volume dalam MMSCF
    heating_quantity_mmbtu FLOAT,     -- Heating quantity (MMBTU)
    
    -- Revenue
    harga_kontrak_per_sm3 FLOAT,
    total_revenue_idr FLOAT,
    
    created_date DATETIME DEFAULT GETDATE()
);

-- ============================================
-- TABEL PARAMETER: Untuk Store Procedure dengan Parameter
-- ============================================
IF OBJECT_ID('dbo.param_case3', 'U') IS NOT NULL 
    DROP TABLE dbo.param_case3;

CREATE TABLE dbo.param_case3 (
    id INT IDENTITY(1,1) PRIMARY KEY,
    param_name VARCHAR(50),
    param_value_float FLOAT,
    param_value_varchar VARCHAR(100),
    param_value_int INT,
    description VARCHAR(255),
    created_date DATETIME DEFAULT GETDATE()
);

-- Insert default parameters
INSERT INTO dbo.param_case3 (param_name, param_value_varchar, description)
VALUES 
    ('customer', 'PT A1', 'Customer untuk perhitungan'),
    ('year', '2022', 'Tahun periode'),
    ('month', '1', 'Bulan periode'),
    ('period', '1', 'Period number');

INSERT INTO dbo.param_case3 (param_name, param_value_float, description)
VALUES 
    ('co2', 0.8477, 'Content of CO2'),
    ('n2', 0.7632, 'Content of N2'),
    ('specific_gravity', 0.5841, 'Specific Gravity'),
    ('temp_awal', 32.0, 'Temperature awal (°C)'),
    ('temp_akhir', 27.0, 'Temperature akhir (°C)');

PRINT '=== CASE 3 STRUCTURE CREATED ===';
PRINT 'Tables created:';
PRINT '1. m_gas_specification - Master gas specification per customer';
PRINT '2. report_case3_aga8 - Report table for AGA8 calculation';
PRINT '3. param_case3 - Parameter table for SP input';
PRINT '';
PRINT 'Next: Create Stored Procedure untuk perhitungan AGA8';
