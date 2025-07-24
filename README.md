# Campaign_Performance_Analysis
This project explores Facebook ad campaign data to evaluate performance and identify the most cost-effective campaigns using SQL.

## 🧰 Tools
- PostgreSQL

## 📊 Dataset
- Table: `facebook_ads_basic_daily`
- Columns: `ad_date`, `campaign_id`, `spend`, `impressions`, `clicks`, `value`

## 🧠 My Tasks
- Grouped data by `ad_date` and `campaign_id`
- Calculated:
  - **Total Spend**: `SUM(spend)`
  - **Total Impressions** / **Clicks** / **Value`
  - **CTR**: `(clicks / impressions) * 100`
  - **CPC**: `(spend / clicks)`
  - **CPM**: `(spend / impressions) * 1000`
  - **ROMI**: `(value / spend) * 100`
- Handled division-by-zero edge cases
- Filtered campaigns with `spend > 500K`
- Selected top-performing campaign by ROMI

## 🧾 Example Queries

```sql
SELECT ad_date, campaign_id,
  SUM(spend) AS total_spend,
  (100 * SUM(clicks) / SUM(impressions)) AS CTR,
  (SUM(spend) / SUM(clicks)) AS CPC,
  (SUM(spend) * 1000 / SUM(impressions)) AS CPM,
  (SUM(value) / SUM(spend)) * 100 AS ROMI
FROM facebook_ads_basic_daily
GROUP BY ad_date, campaign_id
HAVING SUM(clicks) > 0 AND SUM(impressions) > 0 AND SUM(spend) > 0;

✅ Result
Identified the most profitable campaign (ROMI > others)

Gained hands-on practice with KPI logic in SQL

Strengthened skills in grouping, filtering, and reporting

