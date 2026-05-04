# 🍕 Pizza Sales Analysis Dashboard

![Databricks](https://img.shields.io/badge/Databricks-FF3621?style=for-the-badge&logo=databricks&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-4479A1?style=for-the-badge&logo=postgresql&logoColor=white)
![Unity Catalog](https://img.shields.io/badge/Unity_Catalog-FF3621?style=for-the-badge&logo=databricks&logoColor=white)

## 📊 Project Overview

A comprehensive data analytics project analyzing pizza sales data from 2015 to uncover business insights, customer behavior patterns, and revenue optimization opportunities. This project demonstrates end-to-end data analysis using **Databricks SQL** and **Unity Catalog**.

### 🎯 Objectives
- Analyze sales performance across different dimensions (time, category, size, day of week)
- Identify top and bottom-performing products
- Discover customer ordering patterns and behaviors
- Provide actionable insights for business optimization

---

## 📁 Dataset Description

The analysis uses **4 normalized tables** from a pizza restaurant's operational database:

### Tables Overview

| Table | Records | Description |
|-------|---------|-------------|
| **order_details** | 48,620 | Individual pizza items in each order |
| **orders** | 21,350 | Order metadata with date and time |
| **pizzas** | 96 | Pizza SKUs with size and pricing |
| **pizza_types** | 32 | Pizza definitions with categories and ingredients |

### Schema Details

#### `order_details`
```sql
├── order_details_id (BIGINT) - Primary key
├── order_id (BIGINT) - Foreign key to orders
├── pizza_id (STRING) - Foreign key to pizzas
└── quantity (BIGINT) - Number of pizzas ordered
```

#### `orders`
```sql
├── order_id (BIGINT) - Primary key
├── date (DATE) - Order date
└── time (TIMESTAMP) - Order timestamp
```

#### `pizzas`
```sql
├── pizza_id (STRING) - Primary key
├── pizza_type_id (STRING) - Foreign key to pizza_types
├── size (STRING) - S, M, L, XL, XXL
└── price (DOUBLE) - Pizza price
```

#### `pizza_types`
```sql
├── pizza_type_id (STRING) - Primary key
├── name (STRING) - Pizza name
├── category (STRING) - Classic, Supreme, Chicken, Veggie
└── ingredients (STRING) - Comma-separated ingredients list
```

---

## 🧹 Data Cleaning Process

### Quality Checks Performed

#### 1. Null Value Detection
```sql
-- Checked all tables for NULL values in critical columns
-- Result: ✅ No null values found in any table
```

#### 2. Duplicate Detection
```sql
-- Verified uniqueness of primary keys across all tables
-- Result: ✅ No duplicate records found
```

#### 3. Data Integrity Validation
```sql
-- Checked for negative quantities in orders
-- Result: ✅ No negative values found
```

#### 4. Data Type Optimization
```sql
-- Converted quantity from BIGINT to INT using CAST
-- Reason: INT is sufficient for pizza quantities and more memory-efficient
CAST(od.quantity AS INT) AS quantity
```

### Combined Analytics Table

Created a **denormalized `pizza_sales` table** by joining all 4 tables:

```sql
CREATE OR REPLACE TABLE pizza_sales AS
SELECT 
    od.order_details_id,
    od.order_id,
    od.pizza_id,
    CAST(od.quantity AS INT) AS quantity,
    o.date,
    o.time,
    p.pizza_type_id,
    p.size,
    p.price,
    pt.name,
    pt.category,
    pt.ingredients,
    od.quantity * p.price AS total_revenue
FROM order_details od
JOIN orders o ON od.order_id = o.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id;
```

**Result:** 48,620 rows (100% join success rate)

---

## 📈 Analysis & Key Insights

### 1️⃣ Business KPIs

| Metric | Value | Insight |
|--------|-------|----------|
| **Total Revenue** | 817,860.05 | Strong annual performance |
| **Total Orders** | 21,350 | Consistent customer base |
| **Total Pizzas Sold** | 49,574 | High volume sales |
| **Avg Order Value** | 38.31 | Moderate transaction size |
| **Avg Pizzas/Order** | 2.32 | Small group/family orders |

**💡 Key Insights:**
- **Revenue Performance:** Generated 817.8K in total revenue from 21,350 orders across 2015
- **Customer Behavior:** Average 2.32 pizzas per order indicates most orders serve 2-3 people (small groups/families)
- **Sales Volume:** Nearly 50K pizzas sold demonstrates strong, consistent product demand

---

### 2️⃣ Product Performance Analysis

#### Top 5 Best-Selling Pizzas

| Rank | Pizza Name | Revenue |
|------|------------|----------|
| 🥇 1 | The Thai Chicken Pizza | 43,434.25 |
| 🥈 2 | The Barbecue Chicken Pizza | 42,768.00 |
| 🥉 3 | The California Chicken Pizza | 41,409.50 |
| 4 | The Classic Deluxe Pizza | 38,180.50 |
| 5 | The Spicy Italian Pizza | 34,831.25 |

#### Bottom 5 Worst-Selling Pizzas

| Rank | Pizza Name | Revenue |
|------|------------|----------|
| 1 | The Brie Carre Pizza | 11,588.50 |
| 2 | The Mediterranean Pizza | 15,360.50 |
| 3 | The Calabrese Pizza | 15,734.25 |
| 4 | The Spinach Supreme Pizza | 15,596.00 |
| 5 | The Soppressata Pizza | 15,897.00 |

**💡 Key Insights:**
- **Chicken pizzas dominate top sellers** - 3 of top 5 are chicken-based
- **Thai Chicken leads with 43.4K revenue** - 3.7X higher than worst performer
- **Specialty gourmet pizzas underperform** - Brie Carre and Mediterranean struggle despite premium positioning

---

### 3️⃣ Category Analysis

| Category | Revenue | % of Total | Performance |
|----------|---------|------------|-------------|
| **Classic** | 220,053.10 | 27% | 🟢 Leader |
| **Supreme** | 208,197.00 | 25% | 🟢 Strong |
| **Chicken** | 195,919.50 | 24% | 🟡 Good |
| **Veggie** | 193,690.45 | 24% | 🟡 Good |

**💡 Key Insights:**
- **Balanced portfolio:** Only 26K spread across categories (12% variance)
- **Classic pizzas lead** but don't dominate (27% share)
- **No weak performers:** Even the lowest category (Veggie) contributes 24% of total revenue
- **Well-diversified menu** appeals to diverse customer preferences

---

### 4️⃣ Size Analysis

| Size | Revenue | % of Total | Orders |
|------|---------|------------|---------|
| **Large (L)** | 375,318.70 | 46% | ~18,500 |
| **Medium (M)** | 249,382.25 | 30% | ~15,600 |
| **Small (S)** | 178,076.50 | 22% | ~14,800 |
| **X-Large (XL)** | 14,076.00 | 2% | ~550 |
| **XX-Large (XXL)** | 1,006.60 | <1% | ~28 |

**💡 Key Insights:**
- **Large pizzas dominate** with 46% of total revenue
- **Standard sizes (L/M/S) account for 98%** of all sales
- **XL and XXL are niche products** - combined contribute only 2%
- **Opportunity:** Consider discontinuing XXL or repositioning XL/XXL for events/parties

---

### 5️⃣ Time-Based Analysis

#### Hourly Order Distribution

| Time Period | Peak Hours | Orders | % of Daily Total |
|-------------|------------|--------|------------------|
| **Lunch Peak** | 12-1 PM | ~5,000 | 23% |
| **Dinner Peak** | 5-6 PM | ~4,700 | 22% |
| **Afternoon** | 2-4 PM | ~4,860 | 23% |
| **Evening** | 7-9 PM | ~4,850 | 23% |
| **Late Night** | 10-11 PM | ~1,890 | 9% |
| **Morning** | 9-11 AM | <50 | <1% |

**💡 Key Insights:**
- **Bimodal demand pattern:** Clear lunch (12-1 PM) and dinner (5-6 PM) peaks
- **70% of orders** occur during 4-hour window (12-1 PM, 5-7 PM)
- **Minimal morning activity** (before 11 AM) - consider later opening hours
- **Staffing optimization:** Focus resources on lunch and dinner rushes

#### Daily Revenue Patterns

```
Average Daily Revenue: 2,240
Median Daily Revenue: 2,250
Peak Day: Nov 27, 2015 (Thanksgiving) - 4,422.45
Lowest Day: Dec 29, 2015 (Post-Christmas) - 1,337.80
Standard Deviation: ~350 (moderate volatility)
```

**💡 Key Insights:**
- **Holiday spikes:** Thanksgiving weekend generates 2X average revenue
- **Post-Christmas collapse:** Dec 26-30 shows 40% drop below average
- **Event-driven demand:** Major holidays (July 4th, Thanksgiving) create predictable spikes
- **Opportunity:** Develop holiday-specific promotions to capitalize on demand

---

### 6️⃣ Day of Week Analysis

| Day | Revenue | % of Weekly | Rank |
|-----|---------|-------------|------|
| **Friday** | 136,073.90 | 17% | 🥇 1 |
| **Thursday** | 123,528.50 | 15% | 🥈 2 |
| **Saturday** | 123,182.40 | 15% | 🥉 3 |
| **Wednesday** | 114,408.40 | 14% | 4 |
| **Tuesday** | 114,133.80 | 14% | 5 |
| **Monday** | 107,329.55 | 13% | 6 |
| **Sunday** | 99,203.50 | 12% | 7 |

**💡 Key Insights:**
- **Friday is the revenue leader** - 37% higher than Sunday
- **TGIF effect:** Friday date nights and celebrations drive peak demand
- **Weekend underperforms:** Saturday is 3rd, Sunday is worst
- **Opportunity:** Target Sunday promotions to boost weakest day

---

### 7️⃣ Monthly Revenue Trends

| Month | Revenue | Season | Performance |
|-------|---------|--------|-------------|
| **July** | 72,557.90 | Summer | 🔥 Peak |
| **May** | 71,402.75 | Spring | 🔥 Strong |
| **March** | 70,397.10 | Spring | ⬆️ Good |
| **November** | 70,395.35 | Fall | ⬆️ Good |
| **January** | 69,793.30 | Winter | ➡️ Average |
| **April** | 68,736.80 | Spring | ➡️ Average |
| **August** | 68,278.25 | Summer | ➡️ Average |
| **June** | 68,230.20 | Summer | ➡️ Average |
| **February** | 65,159.60 | Winter | ⬇️ Below Avg |
| **December** | 64,701.15 | Winter | ⬇️ Below Avg |
| **September** | 64,180.05 | Fall | 🔻 Weak |
| **October** | 64,027.60 | Fall | 🔻 Weak |

**💡 Key Insights:**
- **Summer dominates:** July leads at 72.5K (13% above weakest months)
- **Fall slump:** Sept-Oct consistently underperform (64K range)
- **Stable year-round:** Only 8.5K spread between best/worst (13% variance)
- **Seasonal pattern:** Summer/Spring outperform Fall/Winter by 10%

---

### 8️⃣ Weekday vs Weekend Analysis

| Day Type | Revenue | % of Total | Avg Daily Revenue |
|----------|---------|------------|-------------------|
| **Weekday** | 595,474.15 | 73% | 119,095 |
| **Weekend** | 222,385.90 | 27% | 111,193 |

**💡 Key Insights:**
- **Weekdays generate 2.7X more total revenue** than weekends
- **Per-day comparison is closer:** Weekdays average 119K/day vs weekends 111K/day
- **Weekday bias:** Business caters primarily to weekday lunch/dinner crowd
- **Opportunity:** Weekend-specific promotions could boost lower weekend volume

---

## 🎯 Strategic Recommendations

### 🔴 Immediate Actions (Quick Wins)

1. **Discontinue XXL Size**
   - Contributes <1% of revenue (1,006.60 on 817K total)
   - Simplifies operations and reduces inventory complexity

2. **Sunday Promotions**
   - Worst performing day (99K vs 136K on Friday)
   - Implement "Sunday Family Special" to boost 37% revenue gap

3. **Post-Holiday Recovery Plan**
   - Dec 26-30 sees 40% revenue drop
   - Create "New Year Deals" to recover post-Christmas slump

### 🟡 Medium-Term Initiatives (1-3 Months)

4. **Optimize Staffing**
   - 70% of orders occur during 12-1 PM and 5-7 PM windows
   - Shift resources from low-traffic hours (before 11 AM, after 10 PM)

5. **Re-evaluate Specialty Pizzas**
   - Bottom 5 performers are gourmet/specialty items
   - Consider replacing Brie Carre (11.5K revenue) with chicken variants

6. **Fall Season Promotions**
   - Sept-Oct consistently underperform (64K vs 72K in July)
   - Launch "Back to School" and "Halloween" themed campaigns

### 🟢 Long-Term Strategy (3-6 Months)

7. **Expand Chicken Pizza Line**
   - 3 of top 5 pizzas are chicken-based
   - Chicken category shows strong customer preference

8. **Weekend Experience Enhancement**
   - Weekend revenue trails weekday by 27%
   - Develop family packages and weekend-exclusive offerings

9. **Event-Driven Marketing**
   - Major holidays generate 2X average revenue
   - Build calendar-based campaigns around predictable spikes

---

## 🛠️ Technologies & Tools

- **Platform:** Databricks Lakehouse
- **Query Engine:** Databricks SQL (Serverless)
- **Compute:** Serverless Starter Warehouse (2X-Small)
- **Catalog:** Unity Catalog (saswat.pintu)
- **Storage:** Delta Lake Format
- **Language:** SQL (ANSI SQL with Databricks extensions)
- **Features Used:**
  - Window functions
  - Date/Time functions (HOUR, DATE_FORMAT, MONTH)
  - Aggregate functions (SUM, COUNT, AVG, ROUND)
  - CASE WHEN statements
  - Multi-table JOINs
  - CTEs (Common Table Expressions)

---

## 📂 Project Structure

```
pizza-sales-analysis/
│
├── data/
│   ├── order_details        (48,620 rows)
│   ├── orders               (21,350 rows)
│   ├── pizzas               (96 rows)
│   └── pizza_types          (32 rows)
│
├── sql/
│   ├── 01_data_cleaning.sql
│   ├── 02_table_creation.sql
│   ├── 03_kpi_analysis.sql
│   ├── 04_product_analysis.sql
│   ├── 05_time_analysis.sql
│   └── 06_insights.sql
│
├── results/
│   ├── business_kpis.csv
│   ├── category_performance.csv
│   ├── daily_revenue.csv
│   └── monthly_trends.csv
│
└── README.md
```

---

## 🚀 How to Run

### Prerequisites
- Databricks workspace access
- Unity Catalog enabled
- SQL Warehouse (Serverless or Classic)

### Setup Steps

1. **Create Catalog and Schema**
```sql
CREATE CATALOG IF NOT EXISTS saswat;
USE CATALOG saswat;
CREATE SCHEMA IF NOT EXISTS pintu;
USE SCHEMA pintu;
```

2. **Load Data Tables**
- Upload CSV files to Databricks volumes or DBFS
- Create tables from files using COPY INTO or CREATE TABLE AS SELECT

3. **Run Analysis Script**
```sql
-- Execute the main analysis SQL file
-- Available in: /Users/[your-email]/pizza_sales.sql.dbquery.ipynb
```

4. **View Results**
- Query results appear in Databricks SQL Editor
- Export to CSV/Excel for reporting
- Create dashboards using Databricks AI/BI Dashboards

---

## 📊 Sample Queries

### Get Top 10 Pizzas by Revenue
```sql
SELECT 
    name AS pizza_name,
    ROUND(SUM(total_revenue), 2) AS total_revenue,
    COUNT(DISTINCT order_id) AS order_count
FROM pizza_sales
GROUP BY name
ORDER BY total_revenue DESC
LIMIT 10;
```

### Hourly Order Pattern
```sql
SELECT 
    HOUR(time) AS hour,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(total_revenue), 2) AS revenue
FROM pizza_sales
GROUP BY HOUR(time)
ORDER BY hour;
```

### Monthly Growth Analysis
```sql
SELECT 
    DATE_FORMAT(date, 'yyyy-MM') AS month,
    ROUND(SUM(total_revenue), 2) AS revenue,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(total_revenue) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM pizza_sales
GROUP BY DATE_FORMAT(date, 'yyyy-MM')
ORDER BY month;
```

---

## 📈 Key Metrics Summary

### Revenue Metrics
- **Total Revenue:** 817,860.05
- **Average Daily Revenue:** 2,240
- **Peak Day Revenue:** 4,422.45 (Nov 27 - Thanksgiving)
- **Lowest Day Revenue:** 1,337.80 (Dec 29 - Post-Christmas)

### Order Metrics
- **Total Orders:** 21,350
- **Average Orders/Day:** 58
- **Peak Hour Orders:** 2,520 (12 PM)
- **Average Order Value:** 38.31

### Product Metrics
- **Total Pizzas Sold:** 49,574
- **Average Pizzas/Order:** 2.32
- **Most Popular Size:** Large (46% of revenue)
- **Top Category:** Classic (27% of revenue)

---

## 🎓 Key Learnings

1. **Data Quality Matters:** Thorough data cleaning revealed 100% data integrity
2. **Joins Preserve Data:** All 48,620 records successfully joined across 4 tables
3. **Time Dimensions Critical:** Hourly, daily, and monthly patterns reveal actionable insights
4. **Category Balance:** Even distribution prevents over-reliance on single product line
5. **Size Preferences:** Customers overwhelmingly prefer standard sizes (L/M/S)

---

## 📞 Contact & Feedback

**Project Author:** Saswat Betta Aptakam  
**Email:** saswatbetta.aptakam@gmail.com  
**Platform:** Databricks  
**Catalog:** saswat.pintu  

---

## 📝 License

This project is created for educational and analytical purposes. Data is anonymized and used for demonstration of SQL analytics capabilities.

---

## 🙏 Acknowledgments

- Databricks for providing the Lakehouse platform
- Unity Catalog for data governance capabilities
- Delta Lake for reliable data storage
- SQL community for best practices and patterns

---

**⭐ If you found this analysis helpful, please star this repository!**

**📊 Built with Databricks SQL | 🚀 Powered by Unity Catalog | 💾 Delta Lake Storage**
