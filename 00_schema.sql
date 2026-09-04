/* =========================================================================
   COMMERCIAL PROPERTY & CASUALTY (P&C) INSURANCE — DATABASE SCHEMA
   ========================================================================= */

-- -------------------------------------------------------------------------
-- AGENT
-- -------------------------------------------------------------------------
CREATE TABLE PNC_AGENT (
    Agent_ID    VARCHAR(20) PRIMARY KEY,
    Agent_Name  VARCHAR(50) NOT NULL,
    Agent_Type  VARCHAR(20) NOT NULL,
    Experience  INT NOT NULL,
    Region      VARCHAR(20) NOT NULL
);

-- -------------------------------------------------------------------------
-- CUSTOMER
-- -------------------------------------------------------------------------
CREATE TABLE PNC_CUSTOMER (
    Client_ID       VARCHAR(20) PRIMARY KEY,
    Name            VARCHAR(50) NOT NULL,
    Company_Name    VARCHAR(100) NOT NULL,
    Industry        VARCHAR(100) NOT NULL,
    Annual_Revenue  NUMERIC(20,2) NOT NULL,
    Employee_Count  INT NOT NULL,
    Credit_Rating   VARCHAR(10),
    Region          VARCHAR(20) NOT NULL
);

-- -------------------------------------------------------------------------
-- PROPERTY
-- -------------------------------------------------------------------------
CREATE TABLE PNC_PROPERTY (
    Property_ID         VARCHAR(20) PRIMARY KEY,
    Client_ID           VARCHAR(20) NOT NULL,
    Property_Type       VARCHAR(50),
    Construction_Type   VARCHAR(50),
    Property_Value      NUMERIC(20,2),
    Year_Built          INT,
    Disaster_Risk_Zone  VARCHAR(30),
    Region              VARCHAR(30),
    FOREIGN KEY (Client_ID) REFERENCES PNC_CUSTOMER(Client_ID)
);

-- -------------------------------------------------------------------------
-- CLAIMS
-- -------------------------------------------------------------------------
CREATE TABLE PNC_CLAIMS (
    Claim_ID         VARCHAR(20) PRIMARY KEY,
    Policy_ID        VARCHAR(20) NOT NULL,
    Loss_Cause       VARCHAR(100) NOT NULL,
    Claimed_Amount   NUMERIC(20,2),
    Approved_Amount  NUMERIC(20,2),
    Claim_Date       DATE NOT NULL,
    Claim_Status     VARCHAR(50) NOT NULL,
    Fraud_Flag       INT NOT NULL,
    Rejection_Reason VARCHAR(100)
);

-- -------------------------------------------------------------------------
-- SALES / POLICIES
-- -------------------------------------------------------------------------
CREATE TABLE PNC_SALES (
    Policy_ID               VARCHAR(30) PRIMARY KEY,
    Client_ID                VARCHAR(30) NOT NULL,
    Property_ID               VARCHAR(30) NOT NULL,
    Agent_id                  VARCHAR(30) NOT NULL,
    Coverage_Type              VARCHAR(30) NOT NULL,
    Coverage_Amount            NUMERIC(20,2) NOT NULL,
    Premium                    NUMERIC(20,2) NOT NULL,
    Deductible                 NUMERIC(20,2) NOT NULL,
    Issue_Date                 DATE NOT NULL,
    Expiry_Date                DATE NOT NULL,
    Risk_Adjustment_Factor     NUMERIC(20,2) NOT NULL,
    FOREIGN KEY (Client_ID)   REFERENCES PNC_CUSTOMER(Client_ID),
    FOREIGN KEY (Agent_ID)    REFERENCES PNC_AGENT(Agent_ID),
    FOREIGN KEY (Property_ID) REFERENCES PNC_PROPERTY(Property_ID)
);

/* =========================================================================
   OPTIONAL — LOAD DATA FROM CSV
   Update the file paths below to point at your local copy of the dataset
   before running (see /data/README.md for where to source the CSVs).
   ========================================================================= */

-- COPY PNC_AGENT (Agent_ID, Agent_Name, Agent_Type, Experience, Region)
-- FROM '/path/to/dataset/AGENT.csv' DELIMITER ',' CSV HEADER;

-- COPY PNC_CUSTOMER (Client_ID, Name, Company_Name, Industry, Annual_Revenue, Employee_Count, Credit_Rating, Region)
-- FROM '/path/to/dataset/CUSTOMER.csv' DELIMITER ',' CSV HEADER;

-- COPY PNC_PROPERTY (Property_ID, Client_ID, Property_Type, Construction_Type, Property_Value, Year_Built, Disaster_Risk_Zone, Region)
-- FROM '/path/to/dataset/PROPERTIES.csv' DELIMITER ',' CSV HEADER;

-- COPY PNC_CLAIMS (Claim_ID, Policy_ID, Loss_Cause, Claimed_Amount, Approved_Amount, Claim_Date, Claim_Status, Fraud_Flag, Rejection_Reason)
-- FROM '/path/to/dataset/CLAIMS.csv' DELIMITER ',' CSV HEADER;

-- COPY PNC_SALES (Policy_ID, Client_ID, Property_ID, Agent_id, Coverage_Type, Coverage_Amount, Premium, Deductible, Issue_Date, Expiry_Date, Risk_Adjustment_Factor)
-- FROM '/path/to/dataset/SALES.csv' DELIMITER ',' CSV HEADER;

/* =========================================================================
   TEARDOWN (drop in FK-safe order)
   ========================================================================= */

-- DROP TABLE IF EXISTS PNC_SALES CASCADE;
-- DROP TABLE IF EXISTS PNC_CLAIMS CASCADE;
-- DROP TABLE IF EXISTS PNC_PROPERTY CASCADE;
-- DROP TABLE IF EXISTS PNC_CUSTOMER CASCADE;
-- DROP TABLE IF EXISTS PNC_AGENT CASCADE;
