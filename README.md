


![Image](https://turbo.vernier.com/wp-content/uploads/2019/12/lab.PSV-31-COMP-pressure_and_temperature.png)

![Image](https://ars.els-cdn.com/content/image/1-s2.0-S1875510018303251-gr2.jpg)



# 🚀 Gas Craddle Billing Calculation System

Sistem **perhitungan billing pemakaian gas craddle/tube** berbasis **SQL Server** dengan **3 metode perhitungan berbeda**:

* **Standard Method**
* **Transparent Method**
* **AGA8 Method (Recommended)**

Sistem ini dirancang untuk kebutuhan **operasional**, **billing customer**, hingga **audit regulator** dengan output volume dan energi yang lengkap.

---

## 📑 Table of Contents

* [Overview](#-overview)
* [Features](#-features)
* [Calculation Methods](#-calculation-methods)
* [Database Structure](#-database-structure)
* [Installation](#-installation)
* [Usage](#-usage)
* [Examples](#-examples)
* [Method Comparison](#-method-comparison)
* [Power BI Integration](#-power-bi-integration)
* [Troubleshooting](#-troubleshooting)
* [Contributing](#-contributing)
* [Changelog](#-changelog)
* [License](#-license)

---

## 🎯 Overview

**Gas Craddle Billing Calculation System** digunakan untuk menghitung konsumsi gas dari **craddle / tube** dengan mempertimbangkan:

* ✅ Tekanan awal & akhir (Bar)
* ✅ Temperatur awal & akhir (°C)
* ✅ Volume silinder (LWC – Liter)
* ✅ Komposisi gas (CO₂, N₂, Specific Gravity)
* ✅ Konversi ke **Standard Cubic Meter (SM³)**
* ✅ Perhitungan **revenue** berdasarkan kontrak
* ✅ Perhitungan **energi (MMBTU)** untuk billing berbasis energi

### Supported Standards

* **ISO 6976** – Gas Calculation
* **AGA8** – American Gas Association Report No. 8

---

## ⭐ Features

### 🔹 Core Features

* 🔢 **3 Calculation Methods**: Standard, Transparent, AGA8
* 🔄 **Automatic Data Matching**: Kirim & ambil dicocokkan otomatis
* 📊 **Multiple Outputs**: SM³, MMSCF, MMBTU, Revenue
* 🎨 **Reporting Views**: Siap dipakai dashboard
* 🔌 **Power BI Ready**

### 🔹 Technical Features

* ⚡ Optimized Stored Procedures
* 📈 Scalable database design
* 🛡️ Data validation & error handling
* 📝 Comprehensive logging
* 🔍 Audit trail support

---

## 📊 Calculation Methods

### 🥉 Case 1: Standard Method

**Best for:** Operasional harian & monitoring internal

```sql
SM3 = LWC × [
 ((P_Kirim + 1.013) / 1.013 × 288.15 / (T_Kirim + 273.15))
-
 ((P_Ambil + 1.013) / 1.013 × 288.15 / (T_Ambil + 273.15))
]
```

**Pros**

* ⚡ Cepat
* 📊 Implementasi sederhana

**Cons**

* ❌ Tidak transparan per tahap
* ❌ Kurang ideal untuk audit

---

### 🥈 Case 2: Transparent Method

**Best for:** Billing customer & audit internal

```sql
SM3_Kirim = LWC × ((P_Kirim + 1.013) / 1.013 × 288.15 / (T_Kirim + 273.15))
SM3_Ambil = LWC × ((P_Ambil + 1.013) / 1.013 × 288.15 / (T_Ambil + 273.15))
SM3_Total = SM3_Kirim - SM3_Ambil
```

**Pros**

* 🔍 Transparan
* ✅ Mudah diaudit

**Cons**

* ⏱️ Lebih kompleks
* 💾 Data lebih banyak

---

### 🥇 Case 3: AGA8 Method ⭐ **RECOMMENDED**

**Best for:** Energy-based billing & standar internasional

```sql
V_std = (V_actual × (P + Pbase) / Pbase) × (Tbase + 273.15) / (T + 273.15)
V_MMSCF = V_SM3 × 0.0353147 / 1000
Q_MMBTU = V_MMSCF × Heating_Value
```

**Gas Specification Required**

* Specific Gravity
* CO₂ Content
* N₂ Content
* Heating Value (BTU/SCF)

**Pros**

* 🎯 Paling akurat
* 🌍 Standar internasional
* 📊 Output lengkap (Volume & Energi)

**Cons**

* 🔧 Setup lebih kompleks
* 📝 Butuh data gas detail

---

## 🗄️ Database Structure

### Master Tables

* `master_trailer` → Kapasitas craddle (LWC)
* `master_customer` → Harga kontrak
* `m_gas_specification` → Spesifikasi gas (Case 3)

### Transaction Tables

| Table                  | Description           |
| ---------------------- | --------------------- |
| `t_pengiriman_craddle` | Raw delivery & pickup |
| `craddle_kirim`        | Temporary kirim       |
| `craddle_ambil`        | Temporary ambil       |
| `report`               | Data matching         |
| `report_case3_aga8`    | Hasil AGA8            |

### Views

* `vw_report_case1`
* `vw_report_case2`
* `vw_report_case3_aga8`
* `vw_compare_case1_vs_case2`

---

## 📥 Installation

### Prerequisites

* SQL Server 2016+
* SQL Server Management Studio (SSMS)
* Permission CREATE TABLE / VIEW / PROCEDURE

### Installation Steps

```bash
git clone https://github.com/yourusername/gas-craddle-billing.git
cd gas-craddle-billing
```

Jalankan script SQL **sesuai urutan** yang tersedia di repository.

---

## 💻 Usage

### Daily Workflow

```sql
EXEC sp_inserttemptabel;
EXEC sp_mencocokkandatacraddle;
```

### Generate Reports

```sql
SELECT * FROM vw_report_case1;
SELECT * FROM vw_report_case2;
SELECT * FROM vw_report_case3_aga8;
```

---

## 📈 Examples

### Case 3 (AGA8 Output)

| Customer | Tanggal    | Craddle | SM3     | MMSCF  | MMBTU | Revenue    |
| -------- | ---------- | ------- | ------- | ------ | ----- | ---------- |
| PT A     | 2021-01-06 | RC-11   | 1895.68 | 0.0669 | 76.28 | 17,061,121 |

---

## 🔄 Method Comparison

| Aspect         | Case 1 | Case 2 | Case 3 |
| -------------- | ------ | ------ | ------ |
| Accuracy       | ⭐⭐⭐    | ⭐⭐⭐    | ⭐⭐⭐⭐⭐  |
| Transparency   | ⭐⭐     | ⭐⭐⭐⭐   | ⭐⭐⭐⭐⭐  |
| Energy Billing | ❌      | ❌      | ✅      |
| Audit Ready    | ⚠️     | ✅      | ✅      |

---

## 📊 Power BI Integration

**Recommended Views**

```
vw_report_case1
vw_report_case2
vw_report_case3_aga8
```

**KPI Examples**

* Total Revenue
* Total Volume (SM3)
* Total Energy (MMBTU)
* Revenue per Customer

---

## 🛠️ Troubleshooting

**Problem:** Stored procedure returns 0 rows
**Solution:**

* Pastikan ETL sudah dijalankan
* Cek master customer & gas specification
* Pastikan data report tidak kosong

---

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Commit changes
4. Open Pull Request

---

## 📝 Changelog

### v1.0.0 – 2026-01-09

* ✅ Case 1, 2, 3 implemented
* ✅ AGA8 calculation
* ✅ Reporting views
* ✅ Power BI ready

---

## 📄 License

Licensed under **MIT License**.

---

## 👥 Authors

**Ghori Ghuraishi Mulyadi**
Initial work – [WVamoss]

---
