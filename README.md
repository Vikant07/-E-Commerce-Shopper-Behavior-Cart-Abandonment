# E-Commerce Shopper Behavior & Cart Abandonment Analysis

An end-to-end data analytics portfolio project exploring shopper behaviour, cart-abandonment indicators, purchase conversion, customer segments, device usage and product preferences using a synthetic e-commerce shopper dataset.

## Project Overview

E-commerce businesses need to understand how shoppers behave and which customer groups show higher cart-abandonment indicators. This project uses shopper-level profile data to explore patterns in shopping activity, abandonment, conversion and customer characteristics.

**Important:** The dataset contains synthetic shopper profiles. Each row represents a shopper profile, not a timestamped website event. Therefore, this project does not claim to reconstruct an exact page-by-page conversion funnel or calculate the actual monetary value of abandoned carts.

## Business Questions

1. How do cart-abandonment indicators vary across shopper groups?
2. Which age and income groups show higher average abandonment?
3. How does average abandonment differ by preferred product category?
4. How do device groups compare in abandonment and purchase-conversion indicators?
5. How are monthly spend and average order value distributed across abandonment groups?
6. What business actions could be investigated based on the observed patterns?

## Dataset

- **Dataset:** E-Commerce Shopper Behavior & Lifestyle (Amazon/Shopify based)
- **Records:** Approximately 1,000,000 synthetic shopper profiles
- **Source format:** CSV
- **Nature:** 100% synthetic data, as described by the dataset publisher
- **Granularity:** One row per shopper profile

The dataset includes demographic, lifestyle, financial, shopping-habit and platform-engagement attributes.

## Tools & Technologies

- **Python:** Pandas, NumPy, Matplotlib
- **SQL:** MySQL 8.0+ for data querying and aggregation
- **Power BI:** Interactive dashboard and KPI reporting
- **GitHub:** Project documentation and version control

## Project Workflow

1. Inspect the dataset structure and data types.
2. Check missing values, exact duplicate rows and repeated user IDs.
3. Clean column names and text fields; convert numeric and date fields.
4. Review percentage scales before formatting.
5. Perform exploratory data analysis.
6. Compare abandonment and conversion indicators across customer segments, devices and preferred categories.
7. Prepare summary outputs for Power BI.
8. Present findings, limitations and recommendations in the report and executive presentation.

## Key Metrics

The executed Python notebook reported the following overall averages:

| Metric | Result |
|---|---:|
| Shopper profiles | 1,000,000 |
| Average cart-abandonment rate | 40.21% |
| Average purchase-conversion rate | 50.00% |
| Average monthly checkout abandonments | 5.00 |
| Average product views per day | 25.02 |
| Average cart items | 5.49 |

These are averages of synthetic shopper-level fields, not counts of real transactions. Refer to the report for methodology, evidence status and interpretation.

## Power BI Dashboard

The report is organised into three pages:

1. **Executive Overview** — headline KPIs, device and category comparisons, income-level conversion and shopping activity.
2. **Customer Behaviour & Segmentation** — age, income, financial-stress and budgeting-style comparisons.
3. **Device & Product Analysis** — device performance, product preferences, payment methods, coupon usage and geographic comparisons.

Dashboard screenshots are included in the project materials where available.

## Project Deliverables

The `reports/` folder contains:

- `Ecommerce_Shopper_Behavior_Analysis_Report.pdf` — management-ready project report.
- `Ecommerce_Shopper_Behavior_Analysis_Report.docx` — editable report.
- `Ecommerce_Shopper_Behavior_Executive_Presentation.pptx` — editable executive presentation.

The Python notebook/script and SQL analysis files are maintained in their respective project folders, if included in this repository.

## Business Recommendations to Investigate

Based on the patterns in this synthetic dataset, possible follow-up actions include:

- Review the mobile shopping experience, while validating whether observed device differences are operationally meaningful.
- Investigate product information, pricing clarity and delivery information for shopper groups with higher abandonment indicators.
- Explore payment and coupon experiences through controlled tests.
- Validate any proposed intervention using real transaction and event-level data before claiming business impact.

These are hypotheses and proposed investigations, not proven causes or measured improvements.

## Limitations

- The dataset is synthetic and does not represent verified real customer behaviour.
- The data is shopper-level, not event-level clickstream data.
- An exact event-based conversion funnel cannot be reconstructed.
- Preferred product category does not identify the product in an abandoned cart.
- Actual abandoned-cart value and lost revenue cannot be calculated from the supplied fields.
- Correlation does not establish causation.
- MySQL query execution and Power BI model/DAX validation depend on access to the relevant database and `.pbix` file; see the report for the validation status.

## How to Use

1. Download or clone this repository.
2. Open the Python notebook in Jupyter or Kaggle and attach the dataset CSV.
3. Run the notebook from top to bottom, setting the correct CSV path if required.
4. Open the SQL script in MySQL Workbench after confirming the source table and database connection.
5. Open the Power BI file if included, refresh the data source and review the report pages.

## Author

Vikant

 
