/* =========================================================================
   SECTION 6 — WINDOW FUNCTIONS (Q91–Q105)
   ========================================================================= */

-- Q91. Rank policies by premium within each coverage type. [RANK]
SELECT COVERAGE_TYPE, PREMIUM,
       RANK() OVER (PARTITION BY COVERAGE_TYPE ORDER BY PREMIUM DESC) AS RANK_PREMIUM
FROM PNC_SALES;


-- Q92. Assign a dense rank to clients by annual revenue (no gaps in rank on ties). [DENSE_RANK]
SELECT CLIENT_ID, ANNUAL_REVENUE,
       DENSE_RANK() OVER (ORDER BY ANNUAL_REVENUE DESC) AS REVENUE_RANK
FROM PNC_CUSTOMER;


-- Q93. Number every claim per policy in chronological order (1st claim, 2nd claim...). [ROW_NUMBER]
SELECT POLICY_ID, APPROVED_AMOUNT,
       ROW_NUMBER() OVER (PARTITION BY POLICY_ID ORDER BY CLAIM_DATE ASC) AS CLAIM_SEQUENCE
FROM PNC_CLAIMS;


-- Q94. Find each region's running (cumulative) total premium over time. [SUM OVER with ORDER BY]
SELECT C.REGION, S.PREMIUM, S.ISSUE_DATE,
       SUM(S.PREMIUM) OVER (PARTITION BY C.REGION ORDER BY S.ISSUE_DATE ASC) AS RUNNING_TOTAL
FROM PNC_SALES S
JOIN PNC_CUSTOMER C ON S.CLIENT_ID = C.CLIENT_ID;


-- Q95. For every claim, show the previous claim's approved amount on the same policy. [LAG]
SELECT POLICY_ID, CLAIM_ID, CLAIM_DATE, APPROVED_AMOUNT,
       LAG(APPROVED_AMOUNT) OVER (PARTITION BY POLICY_ID ORDER BY CLAIM_DATE ASC) AS PREVIOUS_CLAIM_AMOUNT
FROM PNC_CLAIMS;


-- Q96. For every claim, show the NEXT claim's amount on the same policy (time between repeat claims). [LEAD]
SELECT POLICY_ID, CLAIM_ID, APPROVED_AMOUNT, CLAIM_DATE,
       LEAD(APPROVED_AMOUNT) OVER (PARTITION BY POLICY_ID ORDER BY CLAIM_DATE ASC) AS NEXT_CLAIM_AMOUNT
FROM PNC_CLAIMS;


-- Q97. Split all policies into 5 equal-sized premium tiers (a pricing-band report). [NTILE]
SELECT POLICY_ID, PREMIUM,
       NTILE(5) OVER (ORDER BY PREMIUM ASC) AS PRICING_BAND
FROM PNC_SALES;


-- Q98. Show what % of each region's total premium every individual policy represents. [Ratio with SUM OVER]
SELECT C.REGION, S.POLICY_ID, S.PREMIUM,
       ROUND(S.PREMIUM * 100.0 / SUM(S.PREMIUM) OVER (PARTITION BY C.REGION), 2) AS PCT_OF_REGION
FROM PNC_SALES S
JOIN PNC_CUSTOMER C ON S.CLIENT_ID = C.CLIENT_ID;


-- Q99. Find the first and last claim date for each policy in a single row per claim. [MIN/MAX OVER]
SELECT POLICY_ID,
       MIN(CLAIM_DATE) OVER (PARTITION BY POLICY_ID) AS FIRST_CLAIM_DATE,
       MAX(CLAIM_DATE) OVER (PARTITION BY POLICY_ID) AS LAST_CLAIM_DATE
FROM PNC_CLAIMS;


-- Q100. Compute each client's percentile standing for annual revenue. [PERCENT_RANK]
SELECT CLIENT_ID, ANNUAL_REVENUE,
       PERCENT_RANK() OVER (ORDER BY ANNUAL_REVENUE ASC) AS PERCENTILE_STANDING
FROM PNC_CUSTOMER;


-- Q101. Compute a cumulative distribution of claim severity, to find what threshold marks
--       the top 5% most severe claims. [CUME_DIST]
SELECT CLAIM_ID, APPROVED_AMOUNT,
       CUME_DIST() OVER (ORDER BY APPROVED_AMOUNT DESC) AS CUME_DIST
FROM PNC_CLAIMS;


-- Q102. Find the top 3 highest-premium policies per agent. [ROW_NUMBER + filter]
WITH RANKED_POLICIES AS (
    SELECT A.AGENT_ID, A.AGENT_NAME, S.POLICY_ID, S.PREMIUM,
           ROW_NUMBER() OVER (PARTITION BY A.AGENT_ID ORDER BY S.PREMIUM DESC) AS PREMIUM_RANK
    FROM PNC_SALES S
    JOIN PNC_AGENT A ON A.AGENT_ID = S.AGENT_ID
)
SELECT AGENT_ID, AGENT_NAME, POLICY_ID, PREMIUM, PREMIUM_RANK
FROM RANKED_POLICIES
WHERE PREMIUM_RANK <= 3;


-- Q103. Show each policy's premium alongside the average premium for its coverage type,
--       and the difference (over/under priced vs. peers). [AVG OVER]
SELECT POLICY_ID, COVERAGE_TYPE, PREMIUM,
       ROUND(AVG(PREMIUM) OVER (PARTITION BY COVERAGE_TYPE), 2) AS AVG_PREMIUM_FOR_TYPE,
       PREMIUM - ROUND(AVG(PREMIUM) OVER (PARTITION BY COVERAGE_TYPE), 2) AS DIFFERENCE_FROM_AVG
FROM PNC_SALES;


-- Q104. Calculate a 3-claim moving average of claim payouts. [Window frame with ROWS BETWEEN]
SELECT CLAIM_ID, CLAIM_DATE, APPROVED_AMOUNT,
       ROUND(AVG(APPROVED_AMOUNT) OVER (ORDER BY CLAIM_DATE ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS MOVING_AVG_3
FROM PNC_CLAIMS;


-- Q105. For each agent, show how their total premium written compares to the company-wide
--       average agent premium. [Window function mixed with aggregate]
SELECT A.AGENT_ID, A.AGENT_NAME, SUM(P.PREMIUM) AS TOTAL_PREMIUM,
       ROUND(AVG(SUM(P.PREMIUM)) OVER (), 2) AS COMPANY_AVG_AGENT_PREMIUM,
       SUM(P.PREMIUM) - ROUND(AVG(SUM(P.PREMIUM)) OVER (), 2) AS DIFFERENCE_FROM_AVG
FROM PNC_AGENT A
JOIN PNC_SALES P ON A.AGENT_ID = P.AGENT_ID
GROUP BY A.AGENT_ID, A.AGENT_NAME;
