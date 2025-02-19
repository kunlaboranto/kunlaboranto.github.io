CREATE USER US_GDMON IDENTIFIED BY US_GDMON ;
ALTER USER US_GDMON QUOTA UNLIMITED ON USER ;

ALTER USER US_GDMON IDENTIFIED BY MONGDMON;

GRANT CONNECT, RESOURCE TO US_GDMON;
--GRANT DBA TO US_GDMON;

-- ASH Viewer / Lab128

GRANT SELECT ANY SEQUENCE TO US_GDMON ;
--GRANT EXECUTE ANY PROCEDURE TO US_GDMON ;
--REVOKE EXECUTE ANY PROCEDURE FROM US_GDMON ;

-- ONLY IF THIS ACCOUNT SHOULD BE ABLE TO KILL A SESSION.
GRANT ALTER SYSTEM TO US_GDMON;
-- THIS IS NEEDED FOR EXPLAIN PLAN FOR QUERIES ON TABLES IN OTHER SCHEMAS.
GRANT SELECT ANY TABLE TO US_GDMON;
GRANT SELECT ANY DICTIONARY TO US_GDMON;
GRANT EXECUTE ON DBMS_SYSTEM TO US_GDMON;
GRANT EXECUTE ON DBMS_SQLTUNE TO US_GDMON;

/*
-- Oracle
GRANT OEM_MONITOR TO US_GDMON;      -- FOR 10G AND LATER, SEE COMMENTS ABOVE.
GRANT EXECUTE ON DBMS_WORKLOAD_REPOSITORY TO US_GDMON ;     -- Not Lab128
GRANT ADMINISTER SQL MANAGEMENT OBJECT TO US_GDMON;
GRANT EXECUTE ON DBMS_SQLDIAG_INTERNAL TO US_GDMON;
*/
