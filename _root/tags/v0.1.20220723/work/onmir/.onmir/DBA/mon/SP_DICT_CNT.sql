CREATE OR REPLACE PROCEDURE PUBLIC.SP_DICT_CNT
( 
  P_TABLE   VARCHAR(128) default NULL
, P_CNT     NUMBER(10) default 0
)
AUTHID CURRENT_USER
IS
    V_TABLE VARCHAR(128);
    V_OWNER VARCHAR(128);
    V_SQL   VARCHAR(2000);
    V_CNT   NUMBER(10);
    V_SUM   NUMBER;
    V_LOOP  INTEGER;
  
    CURSOR C1 IS
    SELECT TABLE_NAME 
      FROM DICTIONARY 
     WHERE 1=1
       AND TABLE_NAME LIKE '%'||P_TABLE||'%'
       AND TABLE_NAME NOT LIKE '%LATCH'         -- V$LATCH
       --AND TABLE_NAME NOT LIKE 'ALL_%'        -- 45 EA
       AND TABLE_NAME NOT LIKE 'USER_%'         -- 45 EA
       AND TABLE_NAME NOT LIKE 'DBA_%'          -- 36 EA
     ORDER BY TABLE_NAME;
BEGIN
    -- ERR-2F000(17076): application error "buffer overflow limit(20000)" : 
    DBMS_OUTPUT.ENABLE( 200000 );

    V_LOOP := 0;
    V_SUM := 0;

    OPEN C1;
    LOOP
        BEGIN
            FETCH C1 INTO V_TABLE ;
            EXIT WHEN C1%NOTFOUND;

            V_SQL := 'SELECT COUNT(*) AS CNT FROM ' || V_TABLE || ' LIMIT 1' ;

            EXECUTE IMMEDIATE V_SQL INTO V_CNT;

            IF V_CNT >= P_CNT THEN
                V_LOOP := V_LOOP + 1;
                DBMS_OUTPUT.PUT_LINE( LPAD(V_LOOP,4,' ') || ' - ' || TO_CHAR(SYSTIMESTAMP, 'DD_HH24:MI:SS.FF6') || '] ' || LPAD( V_TABLE, 20, ' ' ) || ' = ' || V_CNT );
                V_SUM := V_SUM + V_CNT;
            END IF;

            EXCEPTION 
            WHEN OTHERS 
            THEN CONTINUE;
        END;      
    END LOOP;

    IF V_LOOP > 1 THEN
        DBMS_OUTPUT.PUT_LINE( NULL );
        DBMS_OUTPUT.PUT_LINE( LPAD(' ',4,' ') || ' - ' || TO_CHAR(SYSTIMESTAMP, 'DD_HH24:MI:SS.FF6') || '] ' || LPAD( 'Summary', 20, ' ' ) || ' = ' || V_SUM );
    END IF;
END;
/
