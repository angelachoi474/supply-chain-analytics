## Data Cleaning
SELECT * 
FROM supply_chain.data;

DESCRIBE supply_chain.data;

SELECT COUNT(*)
FROM supply_chain.data;

UPDATE supply_chain.data
SET SKU = REPLACE(SKU, 'SKU', '');

## Product Performance Analysis (Demand Planning)
SELECT `Product type`, SUM(`Number of products sold`) AS total_products_sold
FROM supply_chain.data
GROUP BY `Product type`
ORDER BY total_products_sold DESC;

## Revenue Contribution Analysis - Which products generate the most revenue?
## Top 10 Revenue Generating Products
SELECT SKU, `Product type`, ROUND(`Revenue generated`, 2) AS revenue
FROM supply_chain.data
ORDER BY revenue DESC
LIMIT 10;

SELECT
    `Product type`,
    ROUND(SUM(`Revenue generated`),2) AS total_revenue
FROM supply_chain.data
GROUP BY `Product type`
ORDER BY total_revenue DESC;

## Inventory Management Analysis - Which products have potential stock risk?
SELECT
    SKU, `Product type`, `Stock levels`, `Order quantities`,
    (`Stock levels` - `Order quantities`) AS inventory_gap,
    CASE
        WHEN `Stock levels` < `Order quantities` THEN 'Stock Risk'
        WHEN `Stock levels` = `Order quantities` THEN 'Monitor'
        ELSE 'Sufficient Stock'
    END AS stock_status
FROM supply_chain.data
ORDER BY inventory_gap ASC;

 ## Inventory Turnover - How fast are we selling inventory?
 SELECT
    SKU,
    `Number of products sold`,
    `Stock levels`,
    ROUND(`Number of products sold` / NULLIF(`Stock levels`,0), 2) AS inventory_turnover
FROM supply_chain.data
ORDER BY inventory_turnover DESC;

## High turnover: Popular product, Need frequent replenishment
## Low turnover: Overstock risk

## Supplier Performance Analysis
SELECT 
`Supplier name`, 
ROUND(AVG(`Lead times`), 2) as avg_lead_time, 
ROUND(AVG(`Manufacturing costs`), 2) as avg_manufacturing_cost,
ROUND(AVG(`Defect rates`), 2) as avg_defect_rate
FROM supply_chain.data
GROUP BY `Supplier name`
ORDER BY avg_manufacturing_cost;

/*
Supplier Performance Summary

Supplier 2
- Lowest manufacturing cost
- Competitive lead time
- Strong overall value

Supplier 3
- Fastest replenishment
- Slightly higher manufacturing cost

Supplier 1
- Lowest defect rate
- Highest revenue contribution

Supplier 4
- Highest manufacturing cost
- Longest lead time
- Lowest revenue contribution
*/

## Defect Rates
SELECT
    `Supplier name`,
    AVG(`Defect rates`) AS avg_defect_rate
FROM supply_chain.data
GROUP BY `Supplier name`
ORDER BY avg_defect_rate;

## Lead Time Analysis - Which products take longest to replenish?
SELECT SKU, `Product type`, `Lead times`
FROM supply_chain.data
ORDER BY `Lead times` DESC;

SELECT
    `Product type`,
     ROUND(AVG(`Lead times`),2) AS avg_lead_time
FROM supply_chain.data
GROUP BY `Product type`
ORDER BY avg_lead_time DESC;

## --> Supply chain impact: Safety stock decisions + Reorder planning

## Carrier Performance
SELECT
    `Shipping carriers`,
	ROUND(AVG(`Shipping times`), 2) AS avg_shipping_time,
    ROUND(AVG(`Shipping costs`), 2) AS avg_shipping_costs
FROM supply_chain.data
GROUP BY `Shipping carriers`
ORDER BY avg_shipping_time;

## Quality Control Analysis
SELECT
    SKU,
    `Product type`,
    `Defect rates`,
    `Inspection results`
FROM supply_chain.data
ORDER BY `Defect rates` DESC;

SELECT
 `Supplier name`,
 `Inspection results`,
 COUNT(*) AS total_products
 FROM supply_chain.data
 GROUP BY  `Supplier name`, `Inspection results`
 ORDER BY 
    CASE 
        WHEN `Inspection results` = 'Fail' THEN 1
        WHEN `Inspection results` = 'Pending' THEN 2
        WHEN `Inspection results` = 'Pass' THEN 3
    END,
    total_products DESC;
    
SELECT
    `Supplier name`,
    `Inspection results`,
    COUNT(*) AS total_products,
    ROUND(AVG(`Defect rates`), 2) AS avg_defect_rate
FROM supply_chain.data
GROUP BY  
    `Supplier name`, 
    `Inspection results`
ORDER BY 
    CASE 
        WHEN `Inspection results` = 'Fail' THEN 1
        WHEN `Inspection results` = 'Pending' THEN 2
        WHEN `Inspection results` = 'Pass' THEN 3
    END,
    total_products DESC;

## Manufacturing Efficiency - Does higher production volumes increase costs?
SELECT
	`Product type`,
    ROUND(AVG(`Production volumes`), 2) AS avg_production_volumes,
    ROUND(AVG(`Manufacturing costs`), 2) AS avg_manufacturing_costs
FROM supply_chain.data
GROUP BY `Product type`
ORDER BY avg_production_volumes DESC;
## Skincare appears to be the company's highest-volume product category and likely requires the greatest manufacturing capacity.
## Cosmetics are less expensive to manufacture and are produced in smaller quantities.
## Higher production volumes do not appear to correspond with lower manufacturing costs, indicating that product-specific factors may have a greater impact on manufacturing expenses than production scale.

## Shipping & Logistics Optimization - Which transportation method is cheapest and fastest?
SELECT
`Transportation modes`, 
AVG(`Shipping costs`) AS avg_shipping_cost,
AVG(`Shipping times`) AS avg_shipping_time
FROM supply_chain.data
GROUP BY `Transportation modes`
ORDER BY avg_shipping_time, avg_shipping_cost;

SELECT
`Routes`, 
AVG(`Shipping costs`) AS avg_shipping_cost,
AVG(`Shipping times`) AS avg_shipping_time
FROM supply_chain.data
GROUP BY `Routes`
ORDER BY avg_shipping_cost DESC;

## Total Supplier By Revenue 
SELECT 
`Supplier name`,
ROUND(SUM(`Revenue generated`), 2) AS total_revenue
FROM supply_chain.data
GROUP BY `Supplier name`
ORDER BY total_revenue DESC;

## Updated Supplier Performance Analysis
SELECT 
`Supplier name`, 
ROUND(AVG(`Lead times`), 2) as avg_lead_time, 
ROUND(AVG(`Manufacturing costs`), 2) as avg_manufacturing_cost,
ROUND(AVG(`Defect rates`), 2) as avg_defect_rate, 
ROUND(SUM(`Revenue generated`), 2) AS total_revenue
FROM supply_chain.data
GROUP BY `Supplier name`
ORDER BY total_revenue DESC;
## Supplier 1 appears to be the company's most valuable supplier. Although it isn't the cheapest or fastest, it has the highest revenue and lowest defect rate, suggesting it may be supplying premium or high-demand products. 
## Supplier 2 offers the best cost-performance balance. It has the lowest manufacturing cost while still generating the second-highest revenue, making it a strong candidate for cost-efficient sourcing.
## Supplier 3 is the fastest supplier, but speed alone doesn't translate into the highest revenue. This suggests that lead time isn't the only factor driving supplier value.
## Supplier 5 performs reasonably well in revenue but has the highest defect rate, indicating an opportunity for quality improvement.
## Supplier 4 consistently underperforms across multiple metrics—it has the lowest revenue, highest manufacturing cost, and longest lead time. Based on these metrics, it would be the first supplier to investigate for process improvements or renegotiation.

## Executive Summary
SELECT 
COUNT(DISTINCT SKU) AS total_products,
ROUND(SUM(`Revenue generated`), 2) AS total_revenue,
ROUND(SUM(`Number of products sold`), 2) AS units_sold,
ROUND(AVG(`Lead times`), 2) AS avg_lead_time,
ROUND(AVG(`Defect rates`), 2) AS avg_defect_rate,
ROUND(AVG(`Shipping costs`), 2) AS avg_shipping_cost,
(
        SELECT `Supplier name`
        FROM supply_chain.data
        GROUP BY `Supplier name`
        ORDER BY SUM(`Revenue generated`) DESC
        LIMIT 1
    ) AS top_supplier,
(
    SELECT ROUND(SUM(`Revenue generated`), 2)
    FROM supply_chain.data
    WHERE `Supplier name` = (
        SELECT `Supplier name`
        FROM supply_chain.data
        GROUP BY `Supplier name`
        ORDER BY SUM(`Revenue generated`) DESC
        LIMIT 1
    )
) AS top_supplier_revenue
FROM supply_chain.data;
