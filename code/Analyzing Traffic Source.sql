USE mavenfuzzyfactory;

-- Analyzing Traffic sources
-- exploring earliest date and latest for the dataset

SELECT MIN(created_at)
FROM website_sessions
; -- result 2012-03-19 08:04:16 (the website launch)

SELECT MAX(created_at)
FROM website_sessions
; -- result 2015-03-19 07:59:08

-- find the website traffic 3 months after the website launch 
SELECT 
	utm_source, 
	utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at <= date_add('2012-03-19',INTERVAL 3 MONTH)
GROUP BY utm_source, utm_campaign,http_referer
ORDER BY sessions DESC
; -- gsearch-nonbrand is the leading traffic to mavenfuzzy factory website

-- Analyze the convesion rate for gsearch -nonbrand on the period of 3 month after lauching the website
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

-- find conversion rate of the year 2012 group by device_type
SELECT 
	website_sessions.device_type,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id)/COUNT(DISTINCT website_sessions.website_session_id)*100 AS conv_rate_percentage
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE 
	website_sessions.created_at < '2013-01-01'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY website_sessions.device_type
;

-- Weekly trend from previous analysis
SELECT 
	MIN(DATE(website_sessions.created_at)) AS start_of_week,
    COUNT(DISTINCT CASE WHEN device_type ='desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mobile_sessions,
    COUNT(DISTINCT CASE WHEN device_type ='desktop' THEN orders.order_id ELSE NULL END) AS 	desktop_orders,
    COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN orders.order_id ELSE NULL END) AS 	mobile_orders,
    COUNT(DISTINCT CASE WHEN device_type ='desktop' THEN orders.order_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN device_type ='desktop' THEN website_sessions.website_session_id ELSE NULL END)*100 AS desktop_CVR,
    COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN orders.order_id ELSE NULL END)/
    COUNT(DISTINCT CASE WHEN device_type ='mobile' THEN website_sessions.website_session_id ELSE NULL END)*100 AS mobile_CVR
    
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
WHERE 
	website_sessions.created_at < '2013-01-01'
	AND website_sessions.utm_source = 'gsearch'
    AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY YEAR(website_sessions.created_at),
        WEEK(website_sessions.created_at)
;
        
