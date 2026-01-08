ALTER PROCEDURE dbo.sp_report_craddle_billing
AS
BEGIN
    SET NOCOUNT ON;

    EXEC dbo.sp_match_craddle;

    SELECT 
        r.customer,
        CAST(r.tgl_ambil AS DATE) AS tanggal,
        r.craddle,
        r.p_awal AS p_kirim,
        r.p_akhir AS p_ambil,

        CAST(
            t.lwc * (
                ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) -
                ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
            )
        AS DECIMAL(18,2)) AS nilai_sm3,

        c.rupiah_pjbg AS harga_kontrak,

        CAST(
            (
                t.lwc * (
                    ((r.p_awal + 1.013) / 1.013 * (288.15 / (27 + 273.15))) -
                    ((r.p_akhir + 1.013) / 1.013 * (288.15 / (32 + 273.15)))
                )
            ) * c.rupiah_pjbg
        AS DECIMAL(18,2)) AS revenue_idr

    FROM dbo.report r
    INNER JOIN dbo.master_trailer t
        ON r.craddle = t.nama
    INNER JOIN dbo.master_customer c
        ON r.customer = c.nama
    ORDER BY tanggal ASC;
END
GO
