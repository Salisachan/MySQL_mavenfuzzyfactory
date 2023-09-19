markdown
Copy code
# Maven Fuzzy Factory SQL Project

![MySQL Logo](https://aety.io/wp-content/uploads/2016/11/mysql-logo.png)

## Project Overview

Welcome to the Maven Fuzzy Factory SQL project! This project provides a synthetic dataset that simulates a comprehensive e-commerce environment. We aim to analyze various aspects of the e-commerce platform's operation, focusing on the following key areas:

- **Website Traffic Source Analysis:** Explore where website visitors are coming from, including traffic source (organic or paid) and device type. Analyze the effectiveness of marketing efforts and channel distribution.

- **Website Performance Metrics:** Monitor website performance using metrics like bounce rate and conversion rate. Assess user experience and identify areas for improvement to boost user engagement and sales.

- **Conversion Funnels:** Study conversion funnels to pinpoint areas where users drop off in their journey towards making a purchase. Optimize the user flow to maximize conversions.

- **Product Analysis:** Analyze the product Sales & Product launches, Cross-Sell Analysis, Product Refund Rates etc.

## Important Notice

Please note that the dataset in this repository is incomplete due to file size limitations imposed by GitHub. Only a subset of the dataset is provided here for demonstration purposes.

## Dataset Overview

The dataset comprises seven tables, each serving a specific purpose:

### 1. Products Table

- **Description:** This table contains details about various products available in the e-commerce platform.

### 2. Website Sessions Table

- **Description:** This table tracks website traffic for each session, including information about the traffic source (organic or paid) and the type of device used.

### 3. Website Pageviews Table

- **Description:** This table records the user's navigation path within each website session, providing insights into how users interact with the website.

### 4. Orders Table

- **Description:** The Orders table captures information about customer orders, including the associated website session, user ID, quantity of items purchased, total order value, and the total cost of the order.

### 5. Order Items Table

- **Description:** This table contains detailed information about individual items within each order, including their sales price and cost.

### 6. Order Item Refund Table

- **Description:** The Order Item Refund table provides details about items that have been refunded. It tracks the refunded items, the order they belong to, the user ID, and refund information.

## Sample Queries

Here are some sample SQL queries in this project:

### find the website traffic 3 months after the website launch:

```sql
SELECT 
     utm_source, 
     utm_campaign,
     http_referer,
     COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at <= date_add('2012-03-19',INTERVAL 3 MONTH)
GROUP BY utm_source, utm_campaign,http_referer
ORDER BY sessions DESC;
```


### Analyze the convesion rate for gsearch -nonbrand on the period of 3 month after lauching the website:

```sql
SELECT 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100 AS conv_rate_percentage
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE 
    website_sessions.created_at <= date_add('2012-03-19',INTERVAL 3 MONTH)
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
;

```

### find the landing page trend analysis (total sessions, bounce rate) from 2012-06-19 00:35:54 to end of the year for gsearch nonbrand traffic:

```sql
CREATE TEMPORARY TABLE first_pv_w_count
SELECT 
    website_sessions.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS first_pv_id,
    COUNT(website_pageviews.website_pageview_id) AS count_pageviews
FROM website_sessions
    LEFT JOIN website_pageviews
        ON website_sessions.website_session_id = website_pageviews.website_session_id
WHERE
    website_sessions.created_at BETWEEN '2012-06-19 00:35:54' AND '2013-01-01'
    AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY
    website_sessions.website_session_id
;

SELECT 
    MIN(DATE(website_pageviews.created_at)) AS start_of_week,
    COUNT(DISTINCT website_pageviews.website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN count_pageviews = 1 THEN website_pageviews.website_session_id ELSE NULL END)/
    COUNT(DISTINCT website_pageviews.website_session_id) AS bounce_rate,
    COUNT(DISTINCT CASE WHEN pageview_url = '/lander-1' THEN website_pageviews.website_session_id ELSE NULL END) AS lander_sessions,
    COUNT(DISTINCT CASE WHEN pageview_url = '/home' THEN website_pageviews.website_session_id  ELSE NULL END) AS home_sessions
FROM first_pv_w_count
    LEFT JOIN website_pageviews
        ON website_pageviews.website_pageview_id = first_pv_w_count.first_pv_id
GROUP BY YEAR(website_pageviews.created_at), WEEK(website_pageviews.created_at)
;
```


If you have any questions, please don't hesitate to reach out.
