-- Step 1: Insert dan pisahkan data ke tabel temporary
EXEC sp_inserttemptabel;

-- Step 2: Cocokkan data kirim dan ambil, hitung tekanan akhir
EXEC sp_mencocokkandatacraddle;

-- Step 3-5: Generate laporan final dengan konversi SM3 dan revenue
EXEC sp_bookreport;
