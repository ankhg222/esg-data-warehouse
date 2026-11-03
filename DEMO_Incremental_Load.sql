-- ============================================================
-- DEMO_Incremental_Load.sql
-- Script demo Nap Tang Truong (Incremental Load / Watermark)
-- Muc dich: Chay tren DW_TRAIN de demo cho giao vien
-- ============================================================

USE DW_TRAIN;
GO

-- === BUOC 0: Kiem tra trang thai hien tai ===
SELECT table_name, last_load_year, last_load_dt
FROM dbo.etl_watermark
ORDER BY table_name;

-- Kiem tra so luong row theo nam
SELECT hour_key / 1000000 AS nam, COUNT(*) AS rows_fact_ba_hourly
FROM fact_ba_hourly
GROUP BY hour_key / 1000000
ORDER BY nam;
GO

-- === BUOC 1: RESET VE 2022 (xoa du lieu nam 2023) ===
DELETE FROM dbo.fact_ba_hourly          WHERE hour_key / 1000000 = 2023;
DELETE FROM dbo.fact_plant_annual        WHERE year_key / 10000 = 2023;
DELETE FROM dbo.fact_company_environment_annual WHERE year_key / 10000 = 2023;
DELETE FROM dbo.fact_country_environment_annual WHERE year_key / 10000 = 2023;
DELETE FROM dbo.fact_utility_sales_annual       WHERE year_key / 10000 = 2023;
DELETE FROM dbo.fact_utility_reliability_annual  WHERE year_key / 10000 = 2023;
DELETE FROM dbo.fact_country_social_annual       WHERE year_key / 10000 = 2023;
DELETE FROM dbo.fact_company_esg_rating          WHERE rating_date_key / 10000 = 2023;
DELETE FROM dbo.fact_country_governance_annual   WHERE year_key / 10000 = 2023;
DELETE FROM dbo.bridge_plant_company             WHERE year_key / 10000 = 2023;

-- Reset watermark ve 2022
UPDATE dbo.etl_watermark
SET last_load_year = 2022,
    last_load_dt = GETDATE();

-- Xac nhan reset
SELECT 'SAU RESET' AS giai_doan, table_name, last_load_year
FROM dbo.etl_watermark
ORDER BY table_name;
GO

-- === BUOC 2: CHAY 00_Master_PipeLine.dtsx tu Visual Studio ===
-- SSIS se nap data 2018-2023, filter theo watermark: chi nap <= 2023
-- Watermark se tang tu 2022 -> 2023 sau khi chay xong

-- === BUOC 3: SAU KHI CHAY SSIS - Verify ket qua ===
SELECT 'SAU SSIS LAN 1' AS giai_doan, table_name, last_load_year, last_load_dt
FROM dbo.etl_watermark
ORDER BY table_name;

SELECT 'fact_ba_hourly' AS fact_table, hour_key / 1000000 AS nam, COUNT(*) AS so_dong
FROM fact_ba_hourly GROUP BY hour_key / 1000000
UNION ALL
SELECT 'fact_plant_annual', year_key / 10000, COUNT(*)
FROM fact_plant_annual GROUP BY year_key / 10000
UNION ALL
SELECT 'fact_country_env', year_key / 10000, COUNT(*)
FROM fact_country_environment_annual GROUP BY year_key / 10000
ORDER BY fact_table, nam;
GO

-- === BUOC 4: CHAY LAN 2 - idempotent, khong nap them ===
-- Watermark da = 2023, filter se chan het -> 0 rows added
-- Sau lan 2: last_load_year van = 2023 (CASE WHEN 2023 < 2023 THEN ... ELSE 2023 END)
SELECT 'SAU SSIS LAN 2' AS giai_doan, table_name, last_load_year
FROM dbo.etl_watermark;
GO