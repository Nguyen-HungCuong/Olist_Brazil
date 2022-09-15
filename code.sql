-- Sale Performance
-- 1. Number of orders each year/month
SELECT 
  format_date('%m - %Y',order_purchase_timestamp) as order_purchase_timestamp,
  count(distinct order_id) as no_id
FROM `olist.orders`
GROUP BY 1 ORDER BY 1

-- 2. Calculate Average Orders per month
WITH t1 AS 
(
  SELECT 
    customer_state, 
    -- Format ngày to extract the last day in month
    last_day(date(order_purchase_timestamp)) as order_purchase_timestamp,
    -- Total orders in month
    count(distinct o.order_id) as total_orders,
    -- Total customers in month
    count(distinct up.customer_unique_id) as no_customer,
    -- GMV
    sum(price + freight_value) as GMV
  FROM `olist.order_item` oip  
  LEFT JOIN `olist.orders` o on o.order_id = oip.order_id
  LEFT JOIN `olist.customers`up on o.customer_id = up.customer_id
  GROUP BY 1,2
)

SELECT 
  format_date('%m - %Y',order_purchase_timestamp) as order_purchase_timestamp,
  -- Calculate Average Daily Order ADO: Total_orders in month/ Number days in month
  total_orders/extract(day from date(order_purchase_timestamp)) as ADO,
  -- ADGMV: Average daily GMV: GMV/ Number days in month
  GMV/extract(day from date(order_purchase_timestamp)) as ADGMV,
  -- AOV: Average order value SUm price / total orders
  GMV/total_orders as AOV
FROM t1
ORDER BY ADGMV DESC 

-- 3. Which state has the highest revenue; which city has the highest revenue
