-- Analyzing website performance
USE mavenfuzzyfactory;
-- finding most viewed website pages in 2012
SELECT 
	pageview_url,
    COUNT(DISTINCT website_pageview_id) AS views
FROM website_pageviews
WHERE created_at < '2013-01-01'
GROUP BY pageview_url
ORDER BY views DESC
;

-- finding the first date that page '/lander-1' online
SELECT MIN(created_at)
FROM website_pageviews
WHERE 
	created_at < '2013-01-01'
    AND pageview_url = '/lander-1' 
; -- result 2012-06-19 00:35:54

-- finding the last date that '/home' online
SELECT MAX(created_at)
FROM website_pageviews
WHERE pageview_url = '/home' 
; -- result 2015-03-19 07:59:08

-- finding the top entry page 2012
SELECT 
	website_pageviews.pageview_url,
    COUNT(DISTINCT first_pageview.first_pv_id) AS total_first_pageviews
FROM(
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE 
	created_at < '2013-01-01'
GROUP BY website_session_id
) AS first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.first_pv_id = website_pageviews.website_pageview_id
GROUP BY website_pageviews.pageview_url
;

-- Calculating Bounce rates & Landing Page Tests 
-- STEP 1 : find the first website_pageview_id for relevant sessions
-- STEP 2 : identify the landing page of each session
-- STEP 3 : Counting pageviews for each session, to identify "bounces"
-- STEP 4 : summarize total sessions and bounced sessions, by LP

-- CREATE TEMPORARY TABLE landing_page
SELECT 
	website_pageviews.pageview_url,
    website_pageviews.website_session_id,
    website_pageviews.website_pageview_id
FROM(
SELECT
	website_session_id,
    MIN(website_pageview_id) AS first_pv_id
FROM website_pageviews
WHERE 
	created_at < '2013-01-01'
GROUP BY website_session_id
) AS first_pageview
	LEFT JOIN website_pageviews
		ON first_pageview.first_pv_id = website_pageviews.website_pageview_id
;

CREATE TEMPORARY TABLE bounce_sessions
SELECT
	landing_page.pageview_url,
    landing_page.website_session_id,
    COUNT(DISTINCT website_pageviews.website_pageview_id) AS num_pageview
FROM landing_page
 LEFT JOIN website_pageviews
	ON website_pageviews.website_session_id = landing_page.website_session_id
GROUP BY 	landing_page.pageview_url, landing_page.website_session_id
HAVING num_pageview = 1
;

SELECT 
	landing_page.pageview_url,
    COUNT(DISTINCT landing_page.website_session_id) AS sessions,
    COUNT(DISTINCT bounce_sessions.website_session_id) bounce_session,
	COUNT(DISTINCT bounce_sessions.website_session_id)/
    COUNT(DISTINCT landing_page.website_session_id)*100 AS bounce_rate
FROM landing_page
	LEFT JOIN bounce_sessions
		ON landing_page.website_session_id = bounce_sessions.website_session_id
GROUP BY pageview_url
;

-- finding the landing page trend analysis from 2012-06-19 00:35:54 to end of the year for gsearch nonbrand traffic
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
        
