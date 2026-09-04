/* =========================================================================
   SECTION 1 — BASIC SELECT & FILTERING (Q1–Q15)
   ========================================================================= */

-- Q1. List all corporate clients based in the "West" region.
SELECT *
FROM PNC_CUSTOMER
WHERE REGION = 'West';


-- Q2. Find all properties built before 1990 (older buildings usually carry higher fire risk).
SELECT *
FROM PNC_PROPERTY
WHERE YEAR_BUILT < 1990;


-- Q3. Show all policies with a premium greater than 1,000,000.
SELECT *
FROM PNC_SALES
WHERE PREMIUM > 1000000;


-- Q4. List all claims that were rejected, along with the rejection reason.
SELECT *
FROM PNC_CLAIMS
WHERE CLAIM_STATUS = 'Rejected';


-- Q5. Find all clients with a credit rating of 'A' or 'AA'.
SELECT *
FROM PNC_CUSTOMER
WHERE CREDIT_RATING IN ('A', 'AA');


-- Q6. List properties located in a "High" disaster risk zone.
SELECT *
FROM PNC_PROPERTY
WHERE DISASTER_RISK_ZONE LIKE 'High%';


-- Q7. Find policies issued in the year 2024.
SELECT *
FROM PNC_SALES
WHERE EXTRACT(YEAR FROM ISSUE_DATE) = 2024;


-- Q8. Show claims flagged for potential fraud.
SELECT *
FROM PNC_CLAIMS
WHERE FRAUD_FLAG >= 1;


-- Q9. List all agents with more than 10 years of experience.
SELECT *
FROM PNC_AGENT
WHERE EXPERIENCE > 10;


-- Q10. Find clients whose company name contains the word "Tech".
SELECT *
FROM PNC_CUSTOMER
WHERE COMPANY_NAME LIKE '%Tech%';


-- Q11. List policies where the deductible is more than 4% of the coverage amount (a sign of thin coverage).
SELECT *
FROM PNC_SALES
WHERE DEDUCTIBLE > (0.04 * COVERAGE_AMOUNT);


-- Q12. Show properties with no recorded disaster risk zone (data quality check).
SELECT *
FROM PNC_PROPERTY
WHERE DISASTER_RISK_ZONE IS NULL
   OR TRIM(DISASTER_RISK_ZONE) = '';


-- Q13. Find claims with a claimed amount but no approved amount recorded yet.
SELECT *
FROM PNC_CLAIMS
WHERE APPROVED_AMOUNT = 0
  AND CLAIM_STATUS = 'Under Investigation';


-- Q14. List clients ordered by annual revenue, highest first, limited to the top 20 (your biggest accounts).
SELECT *
FROM PNC_CUSTOMER
ORDER BY ANNUAL_REVENUE DESC
LIMIT 20;


-- Q15. Find policies expiring within the next 30 days from a reference date (renewal outreach list).
SELECT *
FROM PNC_SALES
WHERE EXPIRY_DATE BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '30 days';
