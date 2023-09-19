-- find the number of sales , total_revenue, total margin of the flagship product (monthly) till 
USE mavenfuzzyfactory;
SELECT 	
	YEAR(created_at) AS 'Year',
    MONTH(created_at)AS 'Month',
    COUNT(DISTINCT order_id) AS number_of_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd-cogs_usd) AS total_margin
FROM orders
WHERE created_at < '2013-01-01'
GROUP BY 1,2 
;

-- New product were launched on January 6th, create trend analysis to see montly orders, conversion rate, breakdown of sales by product
SELECT 
	YEAR(website_sessions.created_at) AS 'YEAR',
    MONTH(website_sessions.created_at) AS 'MONTH',
	COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100 AS conv_rate,
    COUNT(DISTINCT CASE WHEN primary_product_id = 1 THEN order_id ELSE NULL END) AS product_one_orders,
    COUNT(DISTINCT CASE WHEN primary_product_id = 2 THEN order_id ELSE NULL END) AS product_two_orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at < '2013-08-30'
GROUP BY 1,2
;

-- analyzing clickthrough pre & post product_2 launch
CREATE TEMPORARY TABLE products_pageviews
SELECT
	website_session_id,
    website_pageview_id,
    created_at,
    CASE
		WHEN created_at < '2013-01-06' THEN 'Pre_product_2'
        WHEN created_at >='2013-01-06' THEN 'Post_product_2'
	ELSE 'uh oh'
    END AS time_period
FROM website_pageviews
WHERE created_at < '2013-04-06'
	AND created_at > '2012-10-06'
    AND pageview_url = '/products'; 

CREATE TEMPORARY TABLE sess_w_next_pageid
SELECT 
	products_pageviews.time_period,
	products_pageviews.website_session_id,
	MIN(website_pageviews.website_pageview_id) AS min_next_pageview_id
FROM products_pageviews
	LEFT JOIN website_pageviews
		ON products_pageviews.website_session_id = website_pageviews.website_session_id
        AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id 
        -- to make the pageview that is come after product page
GROUP BY 1,2;

CREATE TEMPORARY TABLE with_pv_url
SELECT	
	sess_w_next_pageid.time_period,
    sess_w_next_pageid.website_session_id,
    website_pageviews.pageview_url AS next_pv_url
FROM sess_w_next_pageid
	LEFT JOIN website_pageviews
		ON website_pageviews.website_pageview_id = sess_w_next_pageid.min_next_pageview_id;
        
SELECT
	time_period,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN next_pv_url IS NOT NULL THEN website_session_id ELSE NULL END) AS w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pv_url IS NOT NULL THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT website_session_id) AS pct_w_next_pg,
    COUNT(DISTINCT CASE WHEN next_pv_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS to_mrfuzzy,
    COUNT(DISTINCT CASE WHEN next_pv_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT website_session_id) AS pct_to_mrfuzzy,
     COUNT(DISTINCT CASE WHEN next_pv_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS to_lovebear, 
     COUNT(DISTINCT CASE WHEN next_pv_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/
		COUNT(DISTINCT website_session_id) AS pct_to_lovebear
FROM with_pv_url
GROUP BY 1
ORDER BY 1 DESC;