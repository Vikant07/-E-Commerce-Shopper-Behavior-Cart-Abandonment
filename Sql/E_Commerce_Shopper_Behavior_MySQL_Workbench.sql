-- ================================================================
-- E-COMMERCE SHOPPER BEHAVIOR & CART ABANDONMENT ANALYSIS
-- Basic-to-Intermediate SQL | MySQL 8.0+ | MySQL Workbench
-- Source table: projectdata.e_commerce
-- ================================================================
-- HOW TO USE
-- 1. Open this file in MySQL Workbench and connect to your MySQL server.
-- 2. Confirm that the table exists: projectdata.e_commerce.
-- 3. Run STEP 1 to inspect the imported table and data types.
-- 4. Run STEP 2 to create the cleaned view.
-- 5. Run each analysis query in STEP 3 individually or section by section.
-- 6. Run STEP 4 to create summary tables for Power BI.
--
-- SCHEMA NOTES BASED ON THE COLUMN LIST PROVIDED:
-- * income_level is INT. Its numeric codes are kept as supplied. No labels
--   such as High/Medium/Low are invented; add a mapping only if you know it.
-- * has_children, loyalty_program_member, weekend_shopper and
--   premium_subscription are INT flags; this view maps 1=Yes and 0=No.
-- * app_usage_frequency, social_sharing_frequency, reading_habits,
--   exercise_frequency, overall_stress_level, sleep_quality and
--   physical_activity_level are kept numeric because your schema lists INT.
-- * return_rate has no data type shown in your message. This script assumes
--   it is numeric. Confirm it with SHOW COLUMNS before relying on this field.
-- * Rate columns are normalized to 0-1 in the view when stored as 0-100.
--   Always inspect STEP 1.5 to verify the actual source ranges.
--
-- ANALYTICAL LIMITATIONS:
-- * The dataset is synthetic shopper-profile data, not event-level clickstream.
-- * Exact page-by-page view > cart > checkout > purchase funnel cannot be derived.
-- * product_category_preference is a shopper preference, not the category of
--   an identified abandoned cart.
-- * Exact abandoned-cart revenue cannot be calculated without cart-level value.
-- * SQL segment comparisons are descriptive; they do not prove causation.
-- ================================================================

USE projectdata;

-- ================================================================
-- STEP 1: VERIFY TABLE, COLUMNS AND DATA TYPES
-- ================================================================

SELECT COUNT(*) AS total_rows
FROM projectdata.e_commerce;

SHOW COLUMNS FROM projectdata.e_commerce;

SELECT *
FROM projectdata.e_commerce
LIMIT 10;

-- 1.4 Check for duplicate user IDs before analysis.
SELECT
    user_id,
    COUNT(*) AS record_count
FROM projectdata.e_commerce
WHERE user_id IS NOT NULL
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC
LIMIT 20;

-- 1.5 Check raw rate scales before using percentage formatting.
-- If MAX is above 1 and up to 100, values are likely stored as 0-100.
SELECT
    'cart_abandonment_rate' AS metric,
    MIN(cart_abandonment_rate) AS min_value,
    MAX(cart_abandonment_rate) AS max_value
FROM projectdata.e_commerce
UNION ALL
SELECT
    'purchase_conversion_rate',
    MIN(purchase_conversion_rate),
    MAX(purchase_conversion_rate)
FROM projectdata.e_commerce
UNION ALL
SELECT
    'notification_response_rate',
    MIN(notification_response_rate),
    MAX(notification_response_rate)
FROM projectdata.e_commerce
UNION ALL
SELECT
    'return_rate',
    MIN(return_rate),
    MAX(return_rate)
FROM projectdata.e_commerce;

-- ================================================================
-- STEP 2: CREATE A CLEANED VIEW
-- The base table is not changed. This view trims text, replaces blank
-- text with 'Unknown', converts 0/1 flags to Yes/No, and normalizes rates.
-- ================================================================

CREATE OR REPLACE VIEW projectdata.v_e_commerce_clean AS
SELECT
    user_id,
    age,
    COALESCE(NULLIF(TRIM(gender), ''), 'Unknown') AS gender,
    COALESCE(NULLIF(TRIM(country), ''), 'Unknown') AS country,
    COALESCE(NULLIF(TRIM(urban_rural), ''), 'Unknown') AS urban_rural,
    income_level,
    COALESCE(NULLIF(TRIM(employment_status), ''), 'Unknown') AS employment_status,
    COALESCE(NULLIF(TRIM(education_level), ''), 'Unknown') AS education_level,
    COALESCE(NULLIF(TRIM(relationship_status), ''), 'Unknown') AS relationship_status,
    CASE
        WHEN has_children = 1 THEN 'Yes'
        WHEN has_children = 0 THEN 'No'
        ELSE 'Unknown'
    END AS has_children,
    household_size,
    COALESCE(NULLIF(TRIM(occupation), ''), 'Unknown') AS occupation,
    COALESCE(NULLIF(TRIM(ethnicity), ''), 'Unknown') AS ethnicity,
    COALESCE(NULLIF(TRIM(language_preference), ''), 'Unknown') AS language_preference,
    COALESCE(NULLIF(TRIM(device_type), ''), 'Unknown') AS device_type,
    weekly_purchases,
    monthly_spend,
    CASE
        WHEN cart_abandonment_rate IS NULL THEN NULL
        WHEN (SELECT MAX(ABS(cart_abandonment_rate)) FROM projectdata.e_commerce) > 1
            THEN cart_abandonment_rate / 100.0
        ELSE cart_abandonment_rate
    END AS cart_abandonment_rate,
    review_writing_frequency,
    average_order_value,
    COALESCE(NULLIF(TRIM(preferred_payment_method), ''), 'Unknown') AS preferred_payment_method,
    coupon_usage_frequency,
    CASE
        WHEN loyalty_program_member = 1 THEN 'Yes'
        WHEN loyalty_program_member = 0 THEN 'No'
        ELSE 'Unknown'
    END AS loyalty_program_member,
    referral_count,
    COALESCE(NULLIF(TRIM(product_category_preference), ''), 'Unknown') AS product_category_preference,
    COALESCE(NULLIF(TRIM(shopping_time_of_day), ''), 'Unknown') AS shopping_time_of_day,
    CASE
        WHEN weekend_shopper = 1 THEN 'Yes'
        WHEN weekend_shopper = 0 THEN 'No'
        ELSE 'Unknown'
    END AS weekend_shopper,
    impulse_purchases_per_month,
    browse_to_buy_ratio,
    return_frequency,
    COALESCE(NULLIF(TRIM(budgeting_style), ''), 'Unknown') AS budgeting_style,
    brand_loyalty_score,
    impulse_buying_score,
    environmental_consciousness,
    health_conscious_shopping,
    travel_frequency,
    hobby_count,
    social_media_influence_score,
    reading_habits,
    exercise_frequency,
    stress_from_financial_decisions,
    overall_stress_level,
    sleep_quality,
    physical_activity_level,
    mental_health_score,
    daily_session_time_minutes,
    product_views_per_day,
    ad_views_per_day,
    ad_clicks_per_day,
    wishlist_items_count,
    cart_items_average,
    checkout_abandonments_per_month,
    CASE
        WHEN purchase_conversion_rate IS NULL THEN NULL
        WHEN (SELECT MAX(ABS(purchase_conversion_rate)) FROM projectdata.e_commerce) > 1
            THEN purchase_conversion_rate / 100.0
        ELSE purchase_conversion_rate
    END AS purchase_conversion_rate,
    app_usage_frequency,
    CASE
        WHEN notification_response_rate IS NULL THEN NULL
        WHEN (SELECT MAX(ABS(notification_response_rate)) FROM projectdata.e_commerce) > 1
            THEN notification_response_rate / 100.0
        ELSE notification_response_rate
    END AS notification_response_rate,
    account_age_months,
    CASE
        WHEN NULLIF(TRIM(last_purchase_date), '') IS NULL THEN NULL
        ELSE COALESCE(
            STR_TO_DATE(TRIM(last_purchase_date), '%Y-%m-%d'),
            STR_TO_DATE(TRIM(last_purchase_date), '%Y-%m-%d %H:%i:%s'),
            STR_TO_DATE(TRIM(last_purchase_date), '%Y-%m-%dT%H:%i:%s'),
            STR_TO_DATE(TRIM(last_purchase_date), '%d-%m-%Y'),
            STR_TO_DATE(TRIM(last_purchase_date), '%m/%d/%Y')
        )
    END AS last_purchase_date,
    social_sharing_frequency,
    CASE
        WHEN premium_subscription = 1 THEN 'Yes'
        WHEN premium_subscription = 0 THEN 'No'
        ELSE 'Unknown'
    END AS premium_subscription,
    CASE
        WHEN return_rate IS NULL THEN NULL
        WHEN (SELECT MAX(ABS(return_rate)) FROM projectdata.e_commerce) > 1
            THEN return_rate / 100.0
        ELSE return_rate
    END AS return_rate
FROM projectdata.e_commerce;

-- Confirm that the cleaned view was created and returns rows.
SELECT COUNT(*) AS cleaned_view_rows
FROM projectdata.v_e_commerce_clean;

SELECT *
FROM projectdata.v_e_commerce_clean
LIMIT 10;

-- ================================================================
-- STEP 3: BASIC-TO-INTERMEDIATE SQL ANALYSIS
-- Use v_e_commerce_clean for all queries below.
-- ================================================================

-- 01. Total records and unique shoppers
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT user_id) AS unique_shoppers
FROM projectdata.v_e_commerce_clean;

-- 02. Duplicate user IDs
SELECT
    user_id,
    COUNT(*) AS record_count
FROM projectdata.v_e_commerce_clean
WHERE user_id IS NOT NULL
GROUP BY user_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC
LIMIT 20;

-- 03. Missing or unknown values in important fields
SELECT
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS missing_user_id,
    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN device_type = 'Unknown' THEN 1 ELSE 0 END) AS unknown_device,
    SUM(CASE WHEN income_level IS NULL THEN 1 ELSE 0 END) AS missing_income_level,
    SUM(CASE WHEN cart_abandonment_rate IS NULL THEN 1 ELSE 0 END) AS missing_abandonment_rate,
    SUM(CASE WHEN purchase_conversion_rate IS NULL THEN 1 ELSE 0 END) AS missing_conversion_rate,
    SUM(CASE WHEN last_purchase_date IS NULL THEN 1 ELSE 0 END) AS missing_or_unparsed_purchase_date
FROM projectdata.v_e_commerce_clean;

-- 04. Overall shopper and business metrics
SELECT
    COUNT(DISTINCT user_id) AS total_shoppers,
    ROUND(AVG(monthly_spend), 2) AS avg_monthly_spend,
    ROUND(AVG(average_order_value), 2) AS avg_order_value,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_cart_abandonment_pct,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_purchase_conversion_pct,
    ROUND(AVG(checkout_abandonments_per_month), 2) AS avg_checkout_abandonments_per_month
FROM projectdata.v_e_commerce_clean;

-- 05. Validate normalized rate ranges (expected 0 to 1 in the clean view)
SELECT
    'cart_abandonment_rate' AS metric,
    MIN(cart_abandonment_rate) AS min_value,
    MAX(cart_abandonment_rate) AS max_value,
    SUM(CASE WHEN cart_abandonment_rate < 0 OR cart_abandonment_rate > 1 THEN 1 ELSE 0 END) AS outside_0_to_1
FROM projectdata.v_e_commerce_clean
UNION ALL
SELECT
    'purchase_conversion_rate',
    MIN(purchase_conversion_rate),
    MAX(purchase_conversion_rate),
    SUM(CASE WHEN purchase_conversion_rate < 0 OR purchase_conversion_rate > 1 THEN 1 ELSE 0 END)
FROM projectdata.v_e_commerce_clean
UNION ALL
SELECT
    'notification_response_rate',
    MIN(notification_response_rate),
    MAX(notification_response_rate),
    SUM(CASE WHEN notification_response_rate < 0 OR notification_response_rate > 1 THEN 1 ELSE 0 END)
FROM projectdata.v_e_commerce_clean
UNION ALL
SELECT
    'return_rate',
    MIN(return_rate),
    MAX(return_rate),
    SUM(CASE WHEN return_rate < 0 OR return_rate > 1 THEN 1 ELSE 0 END)
FROM projectdata.v_e_commerce_clean;

-- 06. Q1: User-level shopping and abandonment indicators
-- These are profile-level summary metrics, not event-level funnel stages.
SELECT
    ROUND(AVG(product_views_per_day), 2) AS avg_product_views_per_day,
    ROUND(AVG(cart_items_average), 2) AS avg_cart_items,
    ROUND(AVG(checkout_abandonments_per_month), 2) AS avg_monthly_checkout_abandonments,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_cart_abandonment_pct,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_purchase_conversion_pct
FROM projectdata.v_e_commerce_clean;

-- 07. Q2: Abandonment by age group
SELECT
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 18 THEN 'Under 18'
        WHEN age <= 24 THEN '18-24'
        WHEN age <= 34 THEN '25-34'
        WHEN age <= 44 THEN '35-44'
        WHEN age <= 54 THEN '45-54'
        WHEN age <= 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(checkout_abandonments_per_month), 2) AS avg_monthly_abandonments,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_conversion_pct
FROM projectdata.v_e_commerce_clean
GROUP BY age_group
ORDER BY avg_abandonment_pct DESC;

-- 08. Q2: Abandonment by income code and financial-stress score
-- income_level and stress_from_financial_decisions are INT in your schema.
-- Their numeric code meanings are not assumed here.
SELECT
    income_level,
    stress_from_financial_decisions,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(monthly_spend), 2) AS avg_monthly_spend
FROM projectdata.v_e_commerce_clean
GROUP BY income_level, stress_from_financial_decisions
ORDER BY avg_abandonment_pct DESC
LIMIT 30;

-- 09. Q2: Abandonment by budgeting style
SELECT
    budgeting_style,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(impulse_buying_score), 2) AS avg_impulse_buying_score,
    ROUND(AVG(monthly_spend), 2) AS avg_monthly_spend
FROM projectdata.v_e_commerce_clean
GROUP BY budgeting_style
ORDER BY avg_abandonment_pct DESC;

-- 10. Q3: Abandonment by preferred product category
-- This field represents shopper preference, not verified abandoned-cart items.
SELECT
    product_category_preference,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(checkout_abandonments_per_month), 2) AS avg_monthly_checkout_abandonments,
    ROUND(AVG(average_order_value), 2) AS avg_order_value
FROM projectdata.v_e_commerce_clean
GROUP BY product_category_preference
ORDER BY avg_abandonment_pct DESC;

-- 11. Q4: Device performance comparison
SELECT
    device_type,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_conversion_pct,
    ROUND(AVG(daily_session_time_minutes), 2) AS avg_session_minutes,
    ROUND(AVG(cart_items_average), 2) AS avg_cart_items
FROM projectdata.v_e_commerce_clean
GROUP BY device_type
ORDER BY avg_abandonment_pct DESC;

-- 12. Q4: Device performance by age group
SELECT
    device_type,
    CASE
        WHEN age IS NULL THEN 'Unknown'
        WHEN age < 18 THEN 'Under 18'
        WHEN age <= 24 THEN '18-24'
        WHEN age <= 34 THEN '25-34'
        WHEN age <= 44 THEN '35-44'
        WHEN age <= 54 THEN '45-54'
        WHEN age <= 64 THEN '55-64'
        ELSE '65+'
    END AS age_group,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_conversion_pct
FROM projectdata.v_e_commerce_clean
GROUP BY device_type, age_group
ORDER BY device_type, avg_abandonment_pct DESC;

-- 13. Q5: Compare spend and AOV by abandonment group (NOT lost revenue)
WITH shopper_groups AS (
    SELECT
        CASE
            WHEN cart_abandonment_rate >= 0.50 THEN 'High (50% or more)'
            WHEN cart_abandonment_rate >= 0.25 THEN 'Medium (25%-49.9%)'
            WHEN cart_abandonment_rate >= 0 THEN 'Low (below 25%)'
            ELSE 'Unknown'
        END AS abandonment_group,
        user_id,
        monthly_spend,
        average_order_value,
        checkout_abandonments_per_month
    FROM projectdata.v_e_commerce_clean
)
SELECT
    abandonment_group,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(monthly_spend), 2) AS avg_monthly_spend,
    ROUND(AVG(average_order_value), 2) AS avg_order_value,
    ROUND(AVG(checkout_abandonments_per_month), 2) AS avg_monthly_abandonments
FROM shopper_groups
GROUP BY abandonment_group
ORDER BY avg_monthly_abandonments DESC;

-- 14. Intermediate: Rank device groups by abandonment using RANK()
WITH device_summary AS (
    SELECT
        device_type,
        COUNT(DISTINCT user_id) AS shoppers,
        AVG(cart_abandonment_rate) AS avg_abandonment_rate
    FROM projectdata.v_e_commerce_clean
    GROUP BY device_type
)
SELECT
    device_type,
    shoppers,
    ROUND(avg_abandonment_rate * 100, 2) AS avg_abandonment_pct,
    RANK() OVER (ORDER BY avg_abandonment_rate DESC) AS abandonment_rank
FROM device_summary
ORDER BY abandonment_rank;

-- 15. Intermediate: Rank preferred categories using DENSE_RANK()
WITH category_summary AS (
    SELECT
        product_category_preference,
        COUNT(DISTINCT user_id) AS shoppers,
        AVG(cart_abandonment_rate) AS avg_abandonment_rate
    FROM projectdata.v_e_commerce_clean
    GROUP BY product_category_preference
)
SELECT
    product_category_preference,
    shoppers,
    ROUND(avg_abandonment_rate * 100, 2) AS avg_abandonment_pct,
    DENSE_RANK() OVER (ORDER BY avg_abandonment_rate DESC) AS category_rank
FROM category_summary
ORDER BY category_rank;

-- 16. Intermediate: Divide shoppers into monthly-spend quartiles using NTILE()
WITH spend_groups AS (
    SELECT
        user_id,
        monthly_spend,
        cart_abandonment_rate,
        NTILE(4) OVER (ORDER BY monthly_spend) AS spend_quartile
    FROM projectdata.v_e_commerce_clean
    WHERE monthly_spend IS NOT NULL
)
SELECT
    spend_quartile,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(monthly_spend), 2) AS avg_monthly_spend,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct
FROM spend_groups
GROUP BY spend_quartile
ORDER BY spend_quartile;

-- 17. Intermediate: Shopper count by recorded last-purchase month
-- This is a distribution of shopper profile dates, not monthly sales revenue.
SELECT
    DATE_FORMAT(last_purchase_date, '%Y-%m') AS purchase_month,
    COUNT(DISTINCT user_id) AS shoppers_with_purchase_date,
    ROUND(AVG(monthly_spend), 2) AS avg_monthly_spend,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_conversion_pct
FROM projectdata.v_e_commerce_clean
WHERE last_purchase_date IS NOT NULL
GROUP BY DATE_FORMAT(last_purchase_date, '%Y-%m')
ORDER BY purchase_month;

-- 18. Intermediate: Financial stress and impulse-buying behaviour
SELECT
    stress_from_financial_decisions,
    overall_stress_level,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(impulse_buying_score), 2) AS avg_impulse_buying_score,
    ROUND(AVG(impulse_purchases_per_month), 2) AS avg_impulse_purchases,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct
FROM projectdata.v_e_commerce_clean
GROUP BY stress_from_financial_decisions, overall_stress_level
ORDER BY avg_abandonment_pct DESC
LIMIT 30;

-- 19. Intermediate: Coupon usage and purchase behaviour
SELECT
    coupon_usage_frequency,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_conversion_pct,
    ROUND(AVG(average_order_value), 2) AS avg_order_value
FROM projectdata.v_e_commerce_clean
GROUP BY coupon_usage_frequency
ORDER BY coupon_usage_frequency;

-- 20. Intermediate: Loyalty membership and shopping behaviour
SELECT
    loyalty_program_member,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_conversion_pct,
    ROUND(AVG(monthly_spend), 2) AS avg_monthly_spend,
    ROUND(AVG(return_rate) * 100, 2) AS avg_return_pct
FROM projectdata.v_e_commerce_clean
GROUP BY loyalty_program_member
ORDER BY avg_conversion_pct DESC;

-- 21. Intermediate: Notification-response group and abandonment
SELECT
    CASE
        WHEN notification_response_rate >= 0.70 THEN 'High response (70%+)'
        WHEN notification_response_rate >= 0.30 THEN 'Medium response (30%-69.9%)'
        WHEN notification_response_rate >= 0 THEN 'Low response (below 30%)'
        ELSE 'Unknown'
    END AS notification_group,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct,
    ROUND(AVG(purchase_conversion_rate) * 100, 2) AS avg_conversion_pct
FROM projectdata.v_e_commerce_clean
GROUP BY notification_group
ORDER BY avg_abandonment_pct DESC;

-- 22. Intermediate: Return behaviour by preferred product category
SELECT
    product_category_preference,
    COUNT(DISTINCT user_id) AS shoppers,
    ROUND(AVG(return_rate) * 100, 2) AS avg_return_pct,
    ROUND(AVG(return_frequency), 2) AS avg_return_frequency,
    ROUND(AVG(cart_abandonment_rate) * 100, 2) AS avg_abandonment_pct
FROM projectdata.v_e_commerce_clean
GROUP BY product_category_preference
ORDER BY avg_return_pct DESC;

-- ================================================================
-- STEP 4: CREATE SUMMARY TABLES FOR POWER BI
-- Drop/recreate these summary tables when you refresh the source data.
-- ================================================================

DROP TABLE IF EXISTS projectdata.pbi_device_summary;
CREATE TABLE projectdata.pbi_device_summary AS
SELECT
    device_type,
    COUNT(DISTINCT user_id) AS shoppers,
    AVG(cart_abandonment_rate) AS avg_cart_abandonment_rate,
    AVG(purchase_conversion_rate) AS avg_purchase_conversion_rate,
    AVG(daily_session_time_minutes) AS avg_session_minutes,
    AVG(cart_items_average) AS avg_cart_items
FROM projectdata.v_e_commerce_clean
GROUP BY device_type;

DROP TABLE IF EXISTS projectdata.pbi_category_summary;
CREATE TABLE projectdata.pbi_category_summary AS
SELECT
    product_category_preference,
    COUNT(DISTINCT user_id) AS shoppers,
    AVG(cart_abandonment_rate) AS avg_cart_abandonment_rate,
    AVG(average_order_value) AS avg_order_value,
    AVG(checkout_abandonments_per_month) AS avg_checkout_abandonments
FROM projectdata.v_e_commerce_clean
GROUP BY product_category_preference;

DROP TABLE IF EXISTS projectdata.pbi_income_summary;
CREATE TABLE projectdata.pbi_income_summary AS
SELECT
    income_level,
    COUNT(DISTINCT user_id) AS shoppers,
    AVG(cart_abandonment_rate) AS avg_cart_abandonment_rate,
    AVG(purchase_conversion_rate) AS avg_purchase_conversion_rate,
    AVG(monthly_spend) AS avg_monthly_spend
FROM projectdata.v_e_commerce_clean
GROUP BY income_level;

-- Preview the summary tables for Power BI.
SELECT * FROM projectdata.pbi_device_summary ORDER BY avg_cart_abandonment_rate DESC;
SELECT * FROM projectdata.pbi_category_summary ORDER BY avg_cart_abandonment_rate DESC;
SELECT * FROM projectdata.pbi_income_summary ORDER BY avg_purchase_conversion_rate DESC;

-- ================================================================
-- END OF SCRIPT
-- ================================================================
