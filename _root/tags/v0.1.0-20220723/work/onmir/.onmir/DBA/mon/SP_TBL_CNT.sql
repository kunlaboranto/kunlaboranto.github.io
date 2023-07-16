CREATE OR REPLACE PROCEDURE PUBLIC.SP_TBL_CNT
( 
  P_TABLE   VARCHAR(128) default NULL
, P_OWNER   VARCHAR(128) default NULL
)
AUTHID CURRENT_USER
IS
--DECLARE
    V_TABLE VARCHAR(128);
    V_OWNER VARCHAR(128);
    V_SQL   VARCHAR(2000);
    V_CNT   NUMBER(10);
    V_SUM   NUMBER(10);
    V_LOOP  INTEGER;
  
    CURSOR C1 IS
    SELECT TABLE_NAME 
      FROM ALL_TABLES 
     WHERE OWNER = V_OWNER 
       AND TABLE_NAME LIKE '%'||P_TABLE||'%'
     ORDER BY TABLE_NAME;
BEGIN
    V_LOOP := 0;
    V_SUM := 0;

    IF P_OWNER IS NULL THEN
        V_OWNER := SESSION_USER() ;
    END IF;



    OPEN C1;
    LOOP
        BEGIN
            FETCH C1 INTO V_TABLE ;
            EXIT WHEN C1%NOTFOUND;

            V_LOOP := V_LOOP + 1;
            V_SQL := 'SELECT COUNT(*) AS CNT FROM ' || V_TABLE || ' LIMIT 1' ;

            EXECUTE IMMEDIATE V_SQL INTO V_CNT;

            DBMS_OUTPUT.PUT_LINE( LPAD(V_LOOP,2,' ') || ' - ' || TO_CHAR(SYSTIMESTAMP, 'DD_HH24:MI:SS.FF6') || '] ' || LPAD( V_TABLE, 20, ' ' ) || ' = ' || V_CNT );
            V_SUM := V_SUM + V_CNT;

            EXCEPTION 
            WHEN OTHERS 
            THEN CONTINUE;
        END;      
    END LOOP;

    IF V_LOOP > 1 THEN
        DBMS_OUTPUT.PUT_LINE( NULL );
        DBMS_OUTPUT.PUT_LINE( LPAD(' ',2,' ') || ' - ' || TO_CHAR(SYSTIMESTAMP, 'DD_HH24:MI:SS.FF6') || '] ' || LPAD( 'Summary', 20, ' ' ) || ' = ' || V_SUM );
    END IF;
END;
/
