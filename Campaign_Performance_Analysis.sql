WITH all_ads_data AS (
    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend::NUMERIC, 0)       AS spend,
        COALESCE(impressions::INTEGER, 0) AS impressions,
        COALESCE(reach::INTEGER, 0)       AS reach,
        COALESCE(clicks::INTEGER, 0)      AS clicks,
        COALESCE(leads::INTEGER, 0)       AS leads,
        COALESCE(value::NUMERIC, 0)       AS value
    FROM facebook_ads_basic_daily
    UNION ALL
    SELECT
        ad_date,
        url_parameters,
        COALESCE(spend::NUMERIC, 0)       AS spend,
        COALESCE(impressions::INTEGER, 0) AS impressions,
        COALESCE(reach::INTEGER, 0)       AS reach,
        COALESCE(clicks::INTEGER, 0)      AS clicks,
        COALESCE(leads::INTEGER, 0)       AS leads,
        COALESCE(value::NUMERIC, 0)       AS value
    FROM google_ads_basic_daily
),
monthly_aggregated AS (  --вираховую агреговані дані + показники, використовуючи CASE щоб уникнути ділення на 0
    SELECT
        DATE_TRUNC('month', ad_date)::DATE AS ad_month,
        NULLIF(LOWER(SUBSTRING(url_parameters FROM 'utm_campaign=([^&]+)')), 'nan') AS utm_campaign,
        SUM(spend)       AS total_spend,
        SUM(impressions) AS total_impressions,
        SUM(clicks)      AS total_clicks,
        SUM(value)       AS total_value,
        CASE 
            WHEN SUM(impressions) = 0 THEN 0
            ELSE ROUND(SUM(clicks)::NUMERIC / SUM(impressions), 4)
            --задаю клікам тип NUMERIC, бо Integer не дасть 4 знаків після коми
        END AS CTR,
        CASE 
            WHEN SUM(clicks) = 0 THEN 0
            ELSE ROUND(SUM(spend) / SUM(clicks), 2)
        END AS CPC,
        CASE 
            WHEN SUM(impressions) = 0 THEN 0
            ELSE ROUND((SUM(spend) / SUM(impressions)) * 1000, 2)
        END AS CPM,
        CASE 
            WHEN SUM(spend) = 0 THEN 0
            ELSE ROUND(SUM(value) / SUM(spend), 2)
        END AS ROMI
    FROM all_ads_data
    GROUP BY ad_month, utm_campaign
),
final_diff_metrics AS (
    SELECT *,
        -- вираховую попередні значення для майбутнього розрахунку % різниць для кожної кампанії в кожному місяці
        LAG(CTR) OVER (PARTITION BY utm_campaign ORDER BY ad_month)  AS prev_CTR,
        LAG(CPM) OVER (PARTITION BY utm_campaign ORDER BY ad_month)  AS prev_CPM,
        LAG(ROMI) OVER (PARTITION BY utm_campaign ORDER BY ad_month) AS prev_ROMI
    FROM monthly_aggregated
)
SELECT
    ad_month,
    utm_campaign,
    total_spend,
    total_impressions,
    total_clicks,
    total_value,
    CTR,
    CPC,
    CPM,
    ROMI,
    -- відсоткові зміни у порівнянні з минулими показниками:
    ROUND(((CTR - prev_CTR) / NULLIF(prev_CTR, 0)) * 100, 4)   AS CTR_change_pct,
    ROUND(((CPM - prev_CPM) / NULLIF(prev_CPM, 0)) * 100, 2)   AS CPM_change_pct,
    ROUND(((ROMI - prev_ROMI) / NULLIF(prev_ROMI, 0)) * 100, 2) AS ROMI_change_pct
FROM final_diff_metrics
ORDER BY ad_month;