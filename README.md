🚀 Gas Craddle Billing Calculation System
Sistem perhitungan billing pemakaian gas craddle dengan 3 metode berbeda: Standard Method, Transparent Method, dan AGA8 Method.

Tampilkan Gambar
Tampilkan Gambar
Tampilkan Gambar

📑 Table of Contents
Overview
Features
Calculation Methods
Database Structure
Installation
Usage
Examples
Method Comparison
Power BI Integration
Troubleshooting
Contributing
License
🎯 Overview
Sistem ini dirancang untuk menghitung billing pemakaian gas dari craddle/tube dengan mempertimbangkan:

✅ Tekanan awal dan akhir (Bar)
✅ Temperature awal dan akhir (°C)
✅ Volume silinder (Liter)
✅ Komposisi gas (CO2, N2, Specific Gravity)
✅ Konversi ke Standard Cubic Meter (SM3)
✅ Perhitungan revenue berdasarkan harga kontrak
Supported Standards:

ISO 6976 (Gas Calculation)
AGA8 (American Gas Association Report No. 8)
⭐ Features
Core Features
🔢 3 Calculation Methods: Simple, Transparent, dan AGA8
🔄 Automatic Data Matching: Cocokkan data kirim dan ambil otomatis
📊 Multiple Outputs: SM3, MMSCF, MMBTU, Revenue
🎨 Reporting Views: Akses data mudah untuk dashboard
🔌 Power BI Ready: Direct integration support
Technical Features
⚡ Optimized Stored Procedures
📈 Scalable database design
🛡️ Data validation & error handling
📝 Comprehensive logging
🔍 Audit trail support
📊 Calculation Methods
🥉 Case 1: Standard Method
Best for: Operasional harian dan monitoring internal

sql
Formula:
SM3 = LWC × [
    ((P_Kirim + 1.013) / 1.013 × 288.15 / (T_Kirim + 273.15)) - 
    ((P_Ambil + 1.013) / 1.013 × 288.15 / (T_Ambil + 273.15))
]
Pros:

⚡ Fast calculation
📊 Simple implementation
🎯 Accurate for stable gas composition
Cons:

❌ No individual SM3 breakdown
❌ Harder to audit per component
Output:

Volume SM3
Revenue (IDR)
🥈 Case 2: Transparent Method
Best for: Audit internal dan customer billing

sql
Formula:
SM3_Kirim = LWC × [(P_Kirim + 1.013) / 1.013 × 288.15 / (T_Kirim + 273.15)]
SM3_Ambil = LWC × [(P_Ambil + 1.013) / 1.013 × 288.15 / (T_Ambil + 273.15)]
SM3_Total = SM3_Kirim - SM3_Ambil
Pros:

🔍 High transparency (shows SM3 kirim & ambil)
✅ Easy to audit
📋 Better for dispute resolution
Cons:

⏱️ Slightly more complex
💾 More data to store
Output:

SM3 Kirim (at delivery)
SM3 Ambil (at pickup)
SM3 Total (consumption)
Revenue (IDR)
🥇 Case 3: AGA8 Method ⭐ RECOMMENDED
Best for: Energy-based billing dan standar internasional

sql
Formula (FPV2 Method):
V_std = (V_actual × (P + Pbase) / Pbase) × (Tbase + 273.15) / (T + 273.15)
V_MMSCF = V_SM3 × 0.0353147 / 1000
Q_MMBTU = V_MMSCF × Heating_Value
Gas Specification Required:

Specific Gravity (e.g., 0.5841)
CO2 Content (e.g., 84.77%)
N2 Content (e.g., 76.32%)
Heating Value (e.g., 1139.37595 BTU/SCF)
Pros:

🎯 Most accurate calculation
🔬 Considers gas composition
🌍 International standard (AGA8)
📊 Complete output (SM3, MMSCF, MMBTU)
✅ Suitable for regulator audit
Cons:

🔧 More complex setup
📝 Requires gas specification data
Output:

Volume SM3 (Awal, Akhir, Total)
Volume MMSCF (Million Standard Cubic Feet)
Heating Quantity MMBTU (Million BTU)
Revenue (IDR)
🗄️ Database Structure
Master Tables
master_trailer
Stores craddle/trailer capacity information.

sql
CREATE TABLE master_trailer (
    nama NVARCHAR(50),      -- Craddle name (RC-11, RC-34, etc.)
    lwc FLOAT               -- Liquid Water Capacity (Liters)
);
master_customer
Stores customer contract prices.

sql
CREATE TABLE master_customer (
    nama NVARCHAR(100),     -- Customer name
    rupiah_pjbg FLOAT       -- Price per SM3 (IDR)
);
m_gas_specification (Case 3 only)
Stores gas specification per customer.

sql
CREATE TABLE m_gas_specification (
    customer VARCHAR(100),
    specific_gravity FLOAT,
    content_co2 FLOAT,
    content_n2 FLOAT,
    heating_value_btu_scf FLOAT,
    base_pressure_bar FLOAT DEFAULT 1.013258,
    base_temp_celsius FLOAT DEFAULT 30.00
);
Transaction Tables
Table	Description
t_pengiriman_craddle	Source data (delivery & pickup)
craddle_kirim	Temporary: Delivery data
craddle_ambil	Temporary: Pickup data
report	Matched delivery-pickup pairs
report_case3_aga8	Case 3 calculation results
Views
View	Purpose
vw_report_case1	Case 1 reporting
vw_report_case2	Case 2 reporting
vw_report_case3_aga8	Case 3 reporting
vw_compare_case1_vs_case2	Method comparison
📥 Installation
Prerequisites
SQL Server 2016 or newer
SQL Server Management Studio (SSMS)
Database privileges: CREATE TABLE, CREATE PROCEDURE, CREATE VIEW
Step-by-Step Installation
1. Clone repository

bash
git clone https://github.com/yourusername/gas-craddle-billing.git
cd gas-craddle-billing
2. Execute SQL scripts in order

sql
-- 📁 Basic Structure
01_create_tables.sql
02_create_master_tables.sql

-- 🔧 ETL Procedures
03_sp_insert_temp_tabel.sql
04_sp_mencocokan_data_craddle.sql

-- 📊 Case 1 & 2
05_sp_book_report_final.sql          -- Case 1
08_sp_book_report_case2.sql          -- Case 2
09_sp_compare_case1_vs_case2.sql     -- Comparison

-- 🚀 Case 3 (AGA8)
11_case3_aga8_structure.sql
12_sp_case3_aga8_calculation.sql
13_view_case3_aga8.sql

-- 👀 Reporting Views
10_create_views_reporting.sql

-- ✅ Test Execution
07_execute_procedures.sql
3. Verify installation

sql
-- Check tables
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'dbo';

-- Check stored procedures
SELECT * FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE';

-- Check views
SELECT * FROM INFORMATION_SCHEMA.VIEWS;
💻 Usage
Daily Workflow
1️⃣ ETL Process (Morning - Automated via SQL Agent)
sql
-- Step 1: Split delivery and pickup data
EXEC sp_inserttemptabel;

-- Step 2: Match delivery with pickup
EXEC sp_mencocokkandatacraddle;
2️⃣ Generate Reports
Case 1 Report:

sql
-- Via Stored Procedure
EXEC sp_bookreport;

-- Via View (preferred)
SELECT * FROM vw_report_case1;
SELECT * FROM vw_report_case1 WHERE customer = 'PT A';
SELECT * FROM vw_report_case1 WHERE Tanggal >= '2021-01-01';
Case 2 Report:

sql
-- Via Stored Procedure
EXEC sp_bookreport_case2;

-- Via View (preferred)
SELECT * FROM vw_report_case2;
SELECT * FROM vw_report_case2 WHERE customer = 'PT A';
Case 3 Report (AGA8):

sql
-- Via Stored Procedure with parameters
EXEC sp_case3_aga8_calculation 
    @customer = 'PT A',
    @year_period = 2021,
    @month_period = 1,
    @period_number = 1;

-- Via View (preferred)
SELECT * FROM vw_report_case3_aga8;
SELECT * FROM vw_report_case3_aga8 WHERE customer = 'PT A';
3️⃣ Comparison Analysis
sql
-- Compare Case 1 vs Case 2
EXEC sp_compare_case1_vs_case2;

-- Via View
SELECT * FROM vw_compare_case1_vs_case2;
Analytics Queries
Summary per Customer:

sql
SELECT 
    customer,
    COUNT(*) as Total_Transactions,
    SUM(Vol_Total_SM3) as Total_Volume_SM3,
    SUM(Heating_Quantity_MMBTU) as Total_MMBTU,
    SUM(Total_Revenue_IDR) as Total_Revenue
FROM vw_report_case3_aga8
GROUP BY customer
ORDER BY Total_Revenue DESC;
Monthly Summary:

sql
SELECT 
    customer,
    YEAR(Tanggal) as Year,
    MONTH(Tanggal) as Month,
    COUNT(*) as Transactions,
    SUM(Vol_Total_SM3) as Total_SM3,
    SUM(Total_Revenue_IDR) as Revenue
FROM vw_report_case3_aga8
GROUP BY customer, YEAR(Tanggal), MONTH(Tanggal)
ORDER BY Year, Month;
Top 10 Highest Revenue Transactions:

sql
SELECT TOP 10 
    customer, 
    Tanggal, 
    craddle,
    Vol_Total_SM3, 
    Total_Revenue_IDR
FROM vw_report_case3_aga8
ORDER BY Total_Revenue_IDR DESC;
📈 Examples
Case 1 Output
Customer	Tanggal	Craddle	P_Kirim	P_Ambil	Nilai_SM3	Harga_Kontrak	Total_Revenue_IDR
PT A	2021-01-06	RC-11	200	10	1336.10	9000	12,024,900
PT A	2021-01-09	RC-21	185	40	1205.50	9000	10,849,500
Case 2 Output
Customer	Tanggal	Craddle	SM3_Kirim	SM3_Ambil	Hasil_Akhir_SM3	Total_Revenue_IDR
PT A	2021-01-06	RC-11	1811.50	475.40	1336.10	12,024,900
PT A	2021-01-09	RC-21	1680.90	475.40	1205.50	10,849,500
Case 3 Output (AGA8)
Customer	Tanggal	Craddle	Vol_Total_SM3	Vol_Std_MMSCF	Heating_Quantity_MMBTU	Total_Revenue_IDR
PT A	2021-01-06	RC-11	1895.68	0.066945	76.28	17,061,121.6
PT A	2021-01-09	RC-21	1452.03	0.051278	58.42	13,068,261.9
🔄 Method Comparison
Aspect	Case 1	Case 2	Case 3 (AGA8)
Complexity	⭐ Simple	⭐⭐ Medium	⭐⭐⭐⭐⭐ Advanced
Accuracy	⭐⭐⭐ Good	⭐⭐⭐ Good	⭐⭐⭐⭐⭐ Excellent
Transparency	⭐⭐ Low	⭐⭐⭐⭐ High	⭐⭐⭐⭐⭐ Very High
Gas Specification	❌ No	❌ No	✅ Yes
Industry Standard	❌ No	❌ No	✅ AGA8
Output Types	2	4	7
Audit Ready	⚠️ Basic	✅ Good	✅ Excellent
Energy Billing	❌ No	❌ No	✅ Yes (MMBTU)
When to Use Each Method
Use Case 1 if:

✅ Daily operational monitoring
✅ Internal reporting only
✅ Gas composition is stable
✅ Quick calculations needed
Use Case 2 if:

✅ Customer billing (volume-based)
✅ Internal audits
✅ Transparency required
✅ Dispute resolution
Use Case 3 if:

✅ Energy-based billing (MMBTU)
✅ Variable gas composition
✅ International standard compliance
✅ External audits (regulator)
✅ SKK Migas reporting
📊 Power BI Integration
Connection Setup
Server: localhost\SQLEXPRESS02 (adjust to your server)
Database: master (or your database name)
Authentication: Windows Authentication

Recommended Data Sources
plaintext
1. vw_report_case1         → Operational Dashboard
2. vw_report_case2         → Audit Dashboard
3. vw_report_case3_aga8    → Billing & Energy Dashboard
Sample DAX Measures
dax
// Total Revenue
Total Revenue = SUM(vw_report_case3_aga8[Total_Revenue_IDR])

// Total Volume
Total Volume SM3 = SUM(vw_report_case3_aga8[Vol_Total_SM3])

// Total Energy
Total MMBTU = SUM(vw_report_case3_aga8[Heating_Quantity_MMBTU])

// Average Price per SM3
Avg Price per SM3 = DIVIDE([Total Revenue], [Total Volume SM3])

// Transaction Count
Transaction Count = COUNTROWS(vw_report_case3_aga8)
Dashboard KPIs
📊 Total Revenue (IDR)
📈 Total Volume (SM3)
⚡ Total Energy (MMBTU)
💰 Average Price per SM3
📉 Volume Trend (Monthly)
🏢 Revenue by Customer
🚚 Top Performing Craddles
🛠️ Troubleshooting
Problem: "0 rows" when executing SP
Symptoms:

sql
EXEC sp_case3_aga8_calculation @customer = 'PT A';
-- Returns: Query executed successfully. 0 rows
Possible Causes:

❌ report table is empty
❌ Customer not found in master tables
❌ Gas specification not configured (Case 3)
Solutions:

sql
-- Solution 1: Check if data exists
SELECT * FROM dbo.report;
SELECT DISTINCT customer FROM dbo.report;

-- Solution 2: Run ETL first
EXEC sp_inserttemptabel;
EXEC sp_mencocokkandatacraddle;

-- Solution 3: Add gas specification (Case 3)
SELECT * FROM dbo.m_gas_specification;

INSERT INTO dbo.m_gas_specification 
    (customer, specific_gravity, content_co2, content_n2, heating_value_btu_scf)
VALUES 
    ('PT A', 0.5841, 0.8477, 0.7632, 1139.37595);

-- Retry
EXEC sp_case3_aga8_calculation @customer = 'PT A';
Problem: View Returns Empty Results
Cause: Stored Procedure not executed yet

Solution:

sql
-- Execute SP first
EXEC sp_mencocokkandatacraddle;           -- For Case 1 & 2
EXEC sp_case3_aga8_calculation;           -- For Case 3

-- Then query View
SELECT * FROM vw_report_case3_aga8;
Problem: "Object already exists" Error
Cause: Trying to create existing objects

Solution:

sql
-- Tables already have DROP statements in scripts
-- But if needed, manually drop:
DROP TABLE IF EXISTS dbo.report_case3_aga8;
DROP PROCEDURE IF EXISTS dbo.sp_case3_aga8_calculation;
DROP VIEW IF EXISTS dbo.vw_report_case3_aga8;

-- Then re-run the creation scripts
🤝 Contributing
Contributions are welcome! Please follow these guidelines:

How to Contribute
Fork the repository
Create a feature branch (git checkout -b feature/AmazingFeature)
Commit your changes (git commit -m 'Add some AmazingFeature')
Push to the branch (git push origin feature/AmazingFeature)
Open a Pull Request
Coding Standards
✅ Use descriptive table/column names
✅ Add comments for complex logic
✅ Use consistent SQL formatting
✅ Test all changes before committing
✅ Update documentation if needed
Bug Reports
Please include:

SQL Server version
Error message (full text)
Steps to reproduce
Expected vs actual behavior
📝 Changelog
Version 1.0.0 (2026-01-09)
Added:

✅ Case 1: Standard calculation method
✅ Case 2: Transparent calculation method
✅ Case 3: AGA8 method implementation
✅ Master table structures
✅ ETL stored procedures
✅ Reporting views
✅ Complete documentation
Features:

Automatic data matching
Gas specification support
Multiple output formats
Power BI ready views
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

MIT License

Copyright (c) 2026 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
👥 Authors
Your Name - Initial work - YourGitHub
🙏 Acknowledgments
American Gas Association (AGA) for AGA8 standard
ISO for gas calculation standards
SQL Server Community
All contributors
📞 Contact & Support
📧 Email: your.email@example.com
🐛 Issues: GitHub Issues
📖 Wiki: Documentation
💬 Discussions: GitHub Discussions
📚 Additional Resources
AGA8 Standard Documentation
ISO 6976 Gas Calculations
SQL Server Best Practices
Power BI Documentation
🌟 Star History
Tampilkan Gambar

<div align="center">
Made with ❤️ for Gas Industry
⬆ back to top

</div>
