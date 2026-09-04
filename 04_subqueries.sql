/* =========================================================================
   SECTION 4 — SUBQUERIES (Q56–Q75)
   ========================================================================= */

-- Q56. Find clients whose annual revenue is above the company-wide average.
SELECT CLIENT_ID, NAME, ANNUAL_REVENUE
FROM PNC_CUSTOMER
WHERE ANNUAL_REVENUE > (SELECT AVG(ANNUAL_REVENUE) FROM PNC_CUSTOMER);


-- Q57. Find policies with a premium higher than the average premium for their own coverage type.
SELECT S.POLICY_ID, S.COVERAGE_TYPE, S.PREMIUM
FROM PNC_SALES S
WHERE S.PREMIUM > (
    SELECT AVG(S2.PREMIUM)
    FROM PNC_SALES S2
    WHERE S2.COVERAGE_TYPE = S.COVERAGE_TYPE
);


-- Q58. List clients who have at least one property in a "High" disaster risk zone. [IN subquery]
SELECT *
FROM PNC_CUSTOMER
WHERE CLIENT_ID IN (
    SELECT CLIENT_ID FROM PNC_PROPERTY WHERE DISASTER_RISK_ZONE LIKE 'High%'
);


-- Q59. Find policies that have never had any claim filed against them.
SELECT *
FROM PNC_SALES
WHERE POLICY_ID NOT IN (SELECT POLICY_ID FROM PNC_CLAIMS);


-- Q60. Find agents whose average written premium beats every agent in the "Online Platform" agent type. [ALL subquery]
SELECT A.AGENT_ID, ROUND(AVG(S.PREMIUM), 2) AS AVG_PREMIUM
FROM PNC_AGENT A
JOIN PNC_SALES S ON A.AGENT_ID = S.AGENT_ID
GROUP BY A.AGENT_ID
HAVING AVG(S.PREMIUM) > ALL (
    SELECT AVG(S1.PREMIUM)
    FROM PNC_AGENT A1
    JOIN PNC_SALES S1 ON A1.AGENT_ID = S1.AGENT_ID
    WHERE A1.AGENT_TYPE = 'Online Platform'
);


-- Q61. Find the single claim with the highest approved amount, and show its full context. [Scalar subquery in WHERE]
SELECT *
FROM PNC_CLAIMS
WHERE APPROVED_AMOUNT = (SELECT MAX(APPROVED_AMOUNT) FROM PNC_CLAIMS);


-- Q62. Find properties whose value is higher than the average property value in their own region. [Correlated subquery]
SELECT P.PROPERTY_ID, P.PROPERTY_TYPE, P.REGION, P.PROPERTY_VALUE
FROM PNC_PROPERTY P
WHERE P.PROPERTY_VALUE > (
    SELECT AVG(P1.PROPERTY_VALUE)
    FROM PNC_PROPERTY P1
    WHERE P1.REGION = P.REGION
);


-- Q63. List clients who have MORE properties than the average number of properties per client. [Subquery in HAVING]
SELECT C.CLIENT_ID, C.NAME, COUNT(P.PROPERTY_ID) AS PROPERTY_COUNT
FROM PNC_CUSTOMER C
JOIN PNC_PROPERTY P ON C.CLIENT_ID = P.CLIENT_ID
GROUP BY C.CLIENT_ID, C.NAME
HAVING COUNT(P.PROPERTY_ID) > (
    SELECT AVG(CLIENT_PROPERTY_COUNT)
    FROM (
        SELECT CLIENT_ID, COUNT(PROPERTY_ID) AS CLIENT_PROPERTY_COUNT
        FROM PNC_PROPERTY
        GROUP BY CLIENT_ID
    ) SUB
);


-- Q64. Find claims where the approved amount is exactly equal to the claimed amount
--      (100% approval — a fraud-audit sanity check). [EXISTS]
SELECT C.*
FROM PNC_CLAIMS C
WHERE EXISTS (
    SELECT 1 FROM PNC_CLAIMS P
    WHERE P.CLAIM_ID = C.CLAIM_ID
      AND P.APPROVED_AMOUNT = P.CLAIMED_AMOUNT
);


-- Q65. Find the 5 agents with the highest total premium written, using a subquery instead of LIMIT-only ranking.
SELECT A.AGENT_ID, A.AGENT_NAME, T.TOTAL_PREMIUM
FROM (
    SELECT AGENT_ID, SUM(PREMIUM) AS TOTAL_PREMIUM
    FROM PNC_SALES
    GROUP BY AGENT_ID
) T
JOIN PNC_AGENT A ON A.AGENT_ID = T.AGENT_ID
ORDER BY T.TOTAL_PREMIUM DESC
LIMIT 5;


-- Q66. Find clients that do not have any policy with 'Fire' coverage type. [NOT IN]
SELECT CLIENT_ID, NAME
FROM PNC_CUSTOMER
WHERE CLIENT_ID NOT IN (
    SELECT CLIENT_ID FROM PNC_SALES WHERE COVERAGE_TYPE = 'Fire'
);


-- Q67. For each region, find the single most expensive property (subquery per group via correlated MAX).
SELECT P.PROPERTY_ID, P.PROPERTY_VALUE, P.REGION
FROM PNC_PROPERTY P
WHERE P.PROPERTY_VALUE = (
    SELECT MAX(P1.PROPERTY_VALUE)
    FROM PNC_PROPERTY P1
    WHERE P.REGION = P1.REGION
);


-- Q68. Find policies whose deductible is below the minimum deductible seen in their coverage type
--      (a data-quality outlier check).
SELECT S.POLICY_ID, S.DEDUCTIBLE, S.COVERAGE_TYPE
FROM PNC_SALES S
WHERE S.DEDUCTIBLE < (
    SELECT MIN(S1.DEDUCTIBLE) FROM PNC_SALES S1 WHERE S1.COVERAGE_TYPE = S.COVERAGE_TYPE
);


-- Q69. Find clients whose total premium paid exceeds the total approved claims paid out to them
--      (net-profitable clients). [Subquery + JOIN]
SELECT C.CLIENT_ID, C.NAME, SUM(S.PREMIUM) AS TOTAL_PREMIUM
FROM PNC_CUSTOMER C
JOIN PNC_SALES S ON C.CLIENT_ID = S.CLIENT_ID
GROUP BY C.CLIENT_ID, C.NAME
HAVING SUM(S.PREMIUM) > (
    SELECT COALESCE(SUM(CL.APPROVED_AMOUNT), 0)
    FROM PNC_CLAIMS CL
    JOIN PNC_SALES S2 ON CL.POLICY_ID = S2.POLICY_ID
    WHERE S2.CLIENT_ID = C.CLIENT_ID
);


-- Q70. Identify agents with ANY claim linked to their book flagged as fraud. [ANY / EXISTS]
SELECT DISTINCT A.AGENT_ID, A.AGENT_NAME
FROM PNC_AGENT A
JOIN PNC_SALES S ON A.AGENT_ID = S.AGENT_ID
WHERE S.POLICY_ID IN (
    SELECT POLICY_ID FROM PNC_CLAIMS WHERE FRAUD_FLAG = 1
);


-- Q71. Find the second-highest premium policy overall, without using LIMIT/OFFSET. [Nested subquery]
SELECT *
FROM PNC_SALES
WHERE PREMIUM = (
    SELECT MAX(PREMIUM)
    FROM PNC_SALES
    WHERE PREMIUM < (SELECT MAX(PREMIUM) FROM PNC_SALES)
);


-- Q72. Find properties that appear in the policies table more than once (multiple policies covering the same property over time).
SELECT *
FROM PNC_PROPERTY
WHERE PROPERTY_ID IN (
    SELECT P.PROPERTY_ID
    FROM PNC_PROPERTY P
    JOIN PNC_SALES S ON P.PROPERTY_ID = S.PROPERTY_ID
    GROUP BY P.PROPERTY_ID
    HAVING COUNT(*) > 1
);


-- Q73. List industries where the average client revenue is below the overall average revenue across all industries. [Subquery in HAVING]
SELECT INDUSTRY, ROUND(AVG(ANNUAL_REVENUE), 2) AS AVERAGE_REVENUE
FROM PNC_CUSTOMER
GROUP BY INDUSTRY
HAVING AVG(ANNUAL_REVENUE) < (SELECT AVG(ANNUAL_REVENUE) FROM PNC_CUSTOMER);


-- Q74. Find claims tied to the client with the single highest annual revenue (multi-level subquery).
SELECT *
FROM PNC_CLAIMS CL
WHERE CL.POLICY_ID IN (
    SELECT S.POLICY_ID
    FROM PNC_SALES S
    WHERE S.CLIENT_ID = (
        SELECT CLIENT_ID
        FROM PNC_CUSTOMER
        WHERE ANNUAL_REVENUE = (SELECT MAX(ANNUAL_REVENUE) FROM PNC_CUSTOMER)
    )
);

-- Same result, expressed as a scalar-subquery + join instead of nested IN:
SELECT *
FROM PNC_CLAIMS C
JOIN PNC_SALES S ON C.POLICY_ID = S.POLICY_ID
JOIN PNC_CUSTOMER CS ON S.CLIENT_ID = CS.CLIENT_ID
WHERE CS.ANNUAL_REVENUE = (SELECT MAX(ANNUAL_REVENUE) FROM PNC_CUSTOMER);


-- Q75. Find regions where claim frequency is above the national average claim frequency (claims per policy).
SELECT REGION, ROUND(COUNT(C.CLAIM_ID) * 1.0 / COUNT(DISTINCT S.POLICY_ID), 2) AS CLAIM_FREQUENCY
FROM PNC_CUSTOMER CS
JOIN PNC_SALES S ON CS.CLIENT_ID = S.CLIENT_ID
JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID
GROUP BY REGION
HAVING (COUNT(C.CLAIM_ID) * 1.0 / COUNT(DISTINCT S.POLICY_ID)) > (
    SELECT AVG(CLAIM_FREQUENCY)
    FROM (
        SELECT REGION, COUNT(C.CLAIM_ID) * 1.0 / COUNT(DISTINCT S.POLICY_ID) AS CLAIM_FREQUENCY
        FROM PNC_CUSTOMER CS
        JOIN PNC_SALES S ON CS.CLIENT_ID = S.CLIENT_ID
        JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID
        GROUP BY REGION
    ) AS DERIVED
);
