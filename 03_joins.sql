/* =========================================================================
   SECTION 3 — JOINS (Q36–Q55)
   ========================================================================= */

-- Q36. List every policy along with the client's company name and industry.
SELECT S.*, C.COMPANY_NAME, C.INDUSTRY
FROM PNC_SALES S
JOIN PNC_CUSTOMER C ON S.CLIENT_ID = C.CLIENT_ID;


-- Q37. List all policies and their claims, if any (some policies never had a claim).
SELECT *
FROM PNC_SALES S
LEFT JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID;


-- Q38. Find policies that have never had a claim filed (potentially your best-performing book).
SELECT *
FROM PNC_SALES S
LEFT JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID
WHERE C.CLAIM_ID IS NULL;


-- Q39. List every agent and the policies they've written, including agents who currently have zero policies.
SELECT A.AGENT_ID, A.AGENT_NAME, S.CLIENT_ID, C.NAME, S.PREMIUM
FROM PNC_AGENT A
LEFT JOIN PNC_SALES S ON S.AGENT_ID = A.AGENT_ID
LEFT JOIN PNC_CUSTOMER C ON C.CLIENT_ID = S.CLIENT_ID
ORDER BY A.AGENT_NAME;


-- Q40. Combine clients and properties to show which properties belong to which clients, including clients with no properties yet.
SELECT C.NAME, C.CLIENT_ID, P.PROPERTY_ID, P.PROPERTY_TYPE, P.CONSTRUCTION_TYPE,
       P.PROPERTY_VALUE, C.COMPANY_NAME, C.INDUSTRY
FROM PNC_CUSTOMER C
LEFT JOIN PNC_PROPERTY P ON P.CLIENT_ID = C.CLIENT_ID;


-- Q41. Build a full underwriting record: client, property, policy, and agent details in one row per policy.
SELECT S.POLICY_ID, S.COVERAGE_TYPE, S.PREMIUM,
       C.CLAIM_ID, C.LOSS_CAUSE, C.CLAIMED_AMOUNT,
       A.AGENT_NAME, CUS.NAME AS CLIENT_NAME, CUS.COMPANY_NAME,
       CUS.INDUSTRY, P.PROPERTY_TYPE, P.CONSTRUCTION_TYPE, P.PROPERTY_VALUE
FROM PNC_SALES S
LEFT JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID
LEFT JOIN PNC_AGENT A ON A.AGENT_ID = S.AGENT_ID
LEFT JOIN PNC_CUSTOMER CUS ON CUS.CLIENT_ID = S.CLIENT_ID
LEFT JOIN PNC_PROPERTY P ON P.PROPERTY_ID = S.PROPERTY_ID;


-- Q42. Show the full claim lifecycle: client -> property -> policy -> claim, for all approved claims over 5,000,000.
SELECT CUS.CLIENT_ID, CUS.NAME AS CLIENT_NAME, P.PROPERTY_TYPE, P.PROPERTY_VALUE,
       S.POLICY_ID, S.PREMIUM, C.CLAIM_ID, C.APPROVED_AMOUNT
FROM PNC_CUSTOMER CUS
JOIN PNC_PROPERTY P ON CUS.CLIENT_ID = P.CLIENT_ID
JOIN PNC_SALES S ON S.PROPERTY_ID = P.PROPERTY_ID
JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID
WHERE C.CLAIM_STATUS = 'Approved'
  AND C.APPROVED_AMOUNT > 5000000;


-- Q43. Find pairs of clients located in the same region (a self-join on customers, useful for regional account clustering).
SELECT C.CLIENT_ID AS CLIENT_A_ID, C.NAME AS CLIENT_A_NAME,
       C1.CLIENT_ID AS CLIENT_B_ID, C1.NAME AS CLIENT_B_NAME,
       C.REGION
FROM PNC_CUSTOMER C
JOIN PNC_CUSTOMER C1
  ON C.REGION = C1.REGION
 AND C.CLIENT_ID < C1.CLIENT_ID;


-- Q44. List agents paired with every possible region (CROSS JOIN), to build an "agent coverage gap" report
--      showing regions an agent doesn't currently operate in.
SELECT A.AGENT_ID, A.AGENT_NAME, R.REGION
FROM PNC_AGENT A
CROSS JOIN (SELECT DISTINCT REGION FROM PNC_CUSTOMER) R;


-- Q45. Find clients who have properties but no active policies (a sales opportunity list). [LEFT JOIN]
SELECT C.CLIENT_ID, C.NAME AS CLIENT_NAME, P.PROPERTY_ID, S.POLICY_ID, S.PREMIUM
FROM PNC_PROPERTY P
LEFT JOIN PNC_CUSTOMER C ON P.CLIENT_ID = C.CLIENT_ID
LEFT JOIN PNC_SALES S ON S.PROPERTY_ID = P.PROPERTY_ID
WHERE S.POLICY_ID IS NULL;


-- Q46. For each claim, show the property's construction type and disaster risk zone
--      (to study whether older/riskier construction drives more claims).
SELECT C.CLAIM_ID, P.CONSTRUCTION_TYPE, P.DISASTER_RISK_ZONE, C.APPROVED_AMOUNT
FROM PNC_PROPERTY P
JOIN PNC_SALES S ON P.PROPERTY_ID = S.PROPERTY_ID
JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID
WHERE C.CLAIM_STATUS = 'Approved'
ORDER BY P.DISASTER_RISK_ZONE;


-- Q47. List every property and, if insured, its policy's coverage amount — flag properties that
--      are under-insured (coverage amount less than property value).
SELECT P.PROPERTY_ID, P.PROPERTY_TYPE, P.CONSTRUCTION_TYPE,
       P.PROPERTY_VALUE, S.COVERAGE_AMOUNT,
       CASE
           WHEN S.COVERAGE_AMOUNT < P.PROPERTY_VALUE THEN 'Under-Insured'
           ELSE 'Over-Insured'
       END AS INSURANCE_STATUS
FROM PNC_PROPERTY P
LEFT JOIN PNC_SALES S ON P.PROPERTY_ID = S.PROPERTY_ID;


-- Q48. Show agents and clients that are in different regions (agent serving an out-of-territory client — a compliance check).
SELECT A.AGENT_ID, A.AGENT_NAME, A.REGION, C.CLIENT_ID, C.NAME AS CLIENT_NAME, C.REGION
FROM PNC_AGENT A
JOIN PNC_SALES S ON S.AGENT_ID = A.AGENT_ID
LEFT JOIN PNC_CUSTOMER C ON S.CLIENT_ID = C.CLIENT_ID
WHERE A.REGION <> C.REGION;


-- Q49. Find the top loss-cause per region by joining claims to policies to clients and grouping.
SELECT REGION, LOSS_CAUSE, TOTAL_CLAIMS
FROM (
    SELECT C.REGION, CL.LOSS_CAUSE, SUM(CL.APPROVED_AMOUNT) AS TOTAL_CLAIMS,
           RANK() OVER (PARTITION BY C.REGION ORDER BY SUM(CL.APPROVED_AMOUNT) DESC) AS RANK_IN_REGION
    FROM PNC_CLAIMS CL
    JOIN PNC_SALES S ON CL.POLICY_ID = S.POLICY_ID
    JOIN PNC_CUSTOMER C ON S.CLIENT_ID = C.CLIENT_ID
    GROUP BY C.REGION, CL.LOSS_CAUSE
) RANKED
WHERE RANK_IN_REGION = 1;


-- Q50. List clients with more than one property, along with the count of properties per client.
SELECT C.CLIENT_ID, C.NAME AS CLIENT_NAME, COUNT(P.PROPERTY_ID) AS COUNT_OF_PROPERTY
FROM PNC_CUSTOMER C
JOIN PNC_PROPERTY P ON C.CLIENT_ID = P.CLIENT_ID
GROUP BY C.CLIENT_ID, C.NAME
HAVING COUNT(P.PROPERTY_ID) > 1;


-- Q51. Show every combination of coverage type and disaster risk zone that actually exists in the book
--      (JOIN + DISTINCT), useful for a product-risk matrix.
SELECT DISTINCT S.COVERAGE_TYPE, P.DISASTER_RISK_ZONE
FROM PNC_SALES S
JOIN PNC_PROPERTY P ON S.PROPERTY_ID = P.PROPERTY_ID
ORDER BY S.COVERAGE_TYPE;


-- Q52. Find claims linked to policies whose property no longer matches any client record
--      (an orphan / data-integrity check using LEFT JOIN).
SELECT C.CLAIM_ID, C.POLICY_ID, C.LOSS_CAUSE, C.CLAIM_DATE, C.CLAIM_STATUS, S.POLICY_ID, P.PROPERTY_ID
FROM PNC_CLAIMS C
LEFT JOIN PNC_SALES S ON C.POLICY_ID = S.POLICY_ID
LEFT JOIN PNC_PROPERTY P ON S.PROPERTY_ID = P.PROPERTY_ID
LEFT JOIN PNC_CUSTOMER CU ON P.CLIENT_ID = CU.CLIENT_ID
WHERE CU.CLIENT_ID IS NULL;


-- Q53. For every agent, show their most recently issued policy (JOIN + subquery for the max date).
SELECT A.AGENT_ID, A.AGENT_NAME, S.POLICY_ID, S.ISSUE_DATE AS RECENT_POLICY
FROM PNC_AGENT A
JOIN PNC_SALES S ON A.AGENT_ID = S.AGENT_ID
WHERE S.ISSUE_DATE = (
    SELECT MAX(S2.ISSUE_DATE) FROM PNC_SALES S2 WHERE S2.AGENT_ID = A.AGENT_ID
)
ORDER BY A.AGENT_NAME ASC;


-- Q54. Compare claim approval rate between "High" and "Low" disaster risk zones (JOIN + conditional aggregation).
SELECT P.DISASTER_RISK_ZONE,
       ROUND((SUM(C.APPROVED_AMOUNT) * 100.0 / SUM(C.CLAIMED_AMOUNT)), 2) AS APPROVAL_RATE
FROM PNC_CLAIMS C
JOIN PNC_SALES S ON C.POLICY_ID = S.POLICY_ID
JOIN PNC_PROPERTY P ON S.PROPERTY_ID = P.PROPERTY_ID
GROUP BY P.DISASTER_RISK_ZONE
ORDER BY APPROVAL_RATE DESC;


-- Q55. Build an "agent scorecard" joining agents to policies and claims: policy count, premium written, and loss ratio per agent.
SELECT A.AGENT_ID, A.AGENT_NAME,
       COUNT(S.POLICY_ID) AS POLICY_COUNT,
       SUM(S.PREMIUM) AS PREMIUM_COLLECTED,
       COALESCE(SUM(C.APPROVED_AMOUNT), 0) AS TOTAL_CLAIMS,
       ROUND((COALESCE(SUM(C.APPROVED_AMOUNT), 0) * 100.0 / NULLIF(SUM(S.PREMIUM), 0)), 2) AS LOSS_RATIO
FROM PNC_AGENT A
LEFT JOIN PNC_SALES S ON A.AGENT_ID = S.AGENT_ID
LEFT JOIN PNC_CLAIMS C ON S.POLICY_ID = C.POLICY_ID
GROUP BY A.AGENT_ID, A.AGENT_NAME
ORDER BY LOSS_RATIO DESC;
