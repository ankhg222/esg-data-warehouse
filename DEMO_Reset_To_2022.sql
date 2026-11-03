-- ============================================================
-- DEMO_Reset_To_2022.sql
-- Mục đích: Reset DB về trạng thái "chỉ có data 2018-2022"
--           để chuẩn bị demo Incremental Load cho thầy
-- Cách dùng: Chạy script này trong SSMS trước khi demo
--            Sau đó chạy Master Pipeline lần 1 → nạp 2023
--            Chạy lần 2 → 0 rows (Idempotent)
-- ============================================================
USE DW_TRAIN;
GO

PRINT '>>> BUOC 1: Xoa data nam 2023 khoi tat ca Fact & Bridge...';

-- fact_ba_hourly: hour_key format yyyyMMddHH -> /1000000 lay nam
DELETE FROM dbo.fact_ba_hourly
WHERE hour_key / 1000000 = 2023;
PRINT CONCAT('   fact_ba_hourly: ', @@ROWCOUNT, ' rows deleted');

-- fact_plant_annual: year_key format yyyyMMDD -> /10000 lay nam
DELETE FROM dbo.fact_plant_annual
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   fact_plant_annual: ', @@ROWCOUNT, ' rows deleted');

-- fact_utility_sales_annual
DELETE FROM dbo.fact_utility_sales_annual
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   fact_utility_sales_annual: ', @@ROWCOUNT, ' rows deleted');

-- fact_utility_reliability_annual
DELETE FROM dbo.fact_utility_reliability_annual
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   fact_utility_reliability_annual: ', @@ROWCOUNT, ' rows deleted');

-- fact_company_esg_rating: rating_date_key format yyyyMMDD
DELETE FROM dbo.fact_company_esg_rating
WHERE rating_date_key / 10000 = 2023;
PRINT CONCAT('   fact_company_esg_rating: ', @@ROWCOUNT, ' rows deleted');

-- fact_company_environment_annual
DELETE FROM dbo.fact_company_environment_annual
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   fact_company_environment_annual: ', @@ROWCOUNT, ' rows deleted');

-- fact_country_environment_annual
DELETE FROM dbo.fact_country_environment_annual
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   fact_country_environment_annual: ', @@ROWCOUNT, ' rows deleted');

-- fact_country_social_annual
DELETE FROM dbo.fact_country_social_annual
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   fact_country_social_annual: ', @@ROWCOUNT, ' rows deleted');

-- fact_country_governance_annual
DELETE FROM dbo.fact_country_governance_annual
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   fact_country_governance_annual: ', @@ROWCOUNT, ' rows deleted');

-- bridge_plant_company
DELETE FROM dbo.bridge_plant_company
WHERE year_key / 10000 = 2023;
PRINT CONCAT('   bridge_plant_company: ', @@ROWCOUNT, ' rows deleted');

PRINT '';
PRINT '>>> BUOC 2: Reset watermark ve 2022...';

UPDATE dbo.etl_watermark
SET last_load_year = 2022,
    last_load_dt   = GETDATE();
PRINT CONCAT('   ', @@ROWCOUNT, ' watermark entries reset to 2022');

PRINT '';
PRINT '>>> BUOC 3: Kiem tra ket qua...';

SELECT table_name,
       last_load_year,
       last_load_dt
FROM dbo.etl_watermark
ORDER BY table_name;

-- Row counts sau khi reset
SELECT 'fact_ba_hourly'                  AS table_name, COUNT(*) AS row_count, MAX(hour_key/1000000) AS max_year FROM dbo.fact_ba_hourly
UNION ALL
SELECT 'fact_plant_annual',              COUNT(*), MAX(year_key/10000) FROM dbo.fact_plant_annual
UNION ALL
SELECT 'fact_utility_sales_annual',      COUNT(*), MAX(year_key/10000) FROM dbo.fact_utility_sales_annual
UNION ALL
SELECT 'fact_utility_reliability_annual',COUNT(*), MAX(year_key/10000) FROM dbo.fact_utility_reliability_annual
UNION ALL
SELECT 'fact_company_esg_rating',        COUNT(*), MAX(rating_date_key/10000) FROM dbo.fact_company_esg_rating
UNION ALL
SELECT 'fact_company_environment_annual',COUNT(*), MAX(year_key/10000) FROM dbo.fact_company_environment_annual
UNION ALL
SELECT 'fact_country_environment_annual',COUNT(*), MAX(year_key/10000) FROM dbo.fact_country_environment_annual
UNION ALL
SELECT 'fact_country_social_annual',     COUNT(*), MAX(year_key/10000) FROM dbo.fact_country_social_annual
UNION ALL
SELECT 'fact_country_governance_annual', COUNT(*), MAX(year_key/10000) FROM dbo.fact_country_governance_annual
UNION ALL
SELECT 'bridge_plant_company',           COUNT(*), MAX(year_key/10000) FROM dbo.bridge_plant_company
ORDER BY 1;

PRINT '';
PRINT '=== RESET HOAN TAT. DB dang o trang thai 2018-2022. ===';
PRINT '=== San sang demo Incremental Load! ===';
GO
