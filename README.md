# 📦 Kirim & Ambil Craddle – SQL Server Stored Procedure

Repository ini berisi kumpulan **Stored Procedure SQL Server** yang dirancang secara **bertingkat (layered)** dan saling terintegrasi dengan **table** dan **view** untuk menangani proses **pengiriman, pengambilan, pencocokan (matching), serta pelaporan billing Craddle**.

Project ini dibuat sebagai **studi kasus, latihan engineering SQL**, sekaligus contoh **best practice re-engineering Stored Procedure**.

---

## 🧩 Struktur Repository

```text
kirim_ambil_craddle/
│
├── case1_case2/
│   └── Stored procedure untuk perbandingan case (case 1 vs case 2)
│
├── dbo.sp_load_craddle_kirim_ambil/
│   └── Stored procedure load & transform data pengiriman dan pengambilan
│
├── dbo.sp_match_craddle/
│   └── Stored procedure pencocokan data kirim dan ambil Craddle
│
├── dbo.sp_report_craddle_billing/
│   └── Stored procedure laporan billing Craddle
│
└── README.md
```

---

## 🎯 Tujuan Project

* Menerapkan **Stored Procedure bertingkat (multi-layer SP)**
* Menggabungkan **table, view, dan stored procedure**
* Membuat alur data yang **terstruktur, reusable, dan scalable**
* Simulasi **case comparison** untuk kebutuhan analisis
* Menyusun **report billing** berbasis hasil matching data

---

## ⚙️ Teknologi yang Digunakan

* **Database**: Microsoft SQL Server
* **Bahasa**: T-SQL
* **Konsep**:

  * Stored Procedure
  * View
  * Data Matching
  * Reporting
  * Re-engineering Query

---

## 🔄 Alur Proses (High Level)

1. **Load Data**

   * Data pengiriman & pengambilan Craddle diproses melalui `sp_load_craddle_kirim_ambil`

2. **Matching Data**

   * Data kirim dan ambil dicocokkan menggunakan `sp_match_craddle`

3. **Case Comparison**

   * Perbandingan hasil berdasarkan skenario case (Case 1 & Case 2)

4. **Reporting**

   * Hasil akhir ditampilkan dalam bentuk laporan billing melalui `sp_report_craddle_billing`

---

## 🧠 Konsep Stored Procedure Bertingkat

Project ini menggunakan pendekatan **layered stored procedure**, yaitu:

* **Base Layer** → Query ke table / view
* **Process Layer** → Transformasi & matching data
* **Report Layer** → Output akhir untuk analisis & billing

Pendekatan ini memudahkan:

* Maintenance
* Debugging
* Pengembangan lanjutan

---

## 🚀 Cara Menggunakan

1. Pastikan database SQL Server sudah tersedia
2. Jalankan script sesuai urutan:

   * Load Procedure
   * Match Procedure
   * Report Procedure
3. Sesuaikan nama database dan schema jika diperlukan
4. Eksekusi stored procedure sesuai kebutuhan report

---

## 📚 Catatan

* Repository ini dibuat untuk **pembelajaran, latihan, dan pengembangan skill SQL**
* Struktur dapat dikembangkan untuk **production-ready** dengan:

  * Error handling (`TRY...CATCH`)
  * Logging
  * Transaction management

---

## 👨‍💻 Author

**Ghori Ghuraishi**
SQL Server • Stored Procedure • Query Engineering
