CREATE OR REPLACE PROCEDURE SYS.SP_TABLE_CNT
(
  A_TABLE_NAME IN VARCHAR(40)
, A_CHK_CNT    IN NUMBER(10) DEFAULT 0
, A_USER_NANE  IN VARCHAR(40) DEFAULT NULL
) AS
    V_USER_NAME         VARCHAR(40);
    V_TABLE_NAME        VARCHAR(40);
    V_KOR_NM            VARCHAR(100);
    V_TABLE_TYPE        VARCHAR(40);
    V_TABLE_ID          VARCHAR(40);
    V_TABLE_OID         VARCHAR(40);
    V_SQL               VARCHAR(1024);
    V_CNT_TB_SUM        NUMBER(19);
    V_CNT_TB            NUMBER(10);
    V_CNT               NUMBER(10);
    V_LEN15             NUMBER(10);
    V_LEN05             NUMBER(10);
    V_LEN14             NUMBER(10);

    CURSOR C1
    IS
    SELECT U.USER_NAME
         , T.TABLE_NAME
         , DECODE(T.TABLE_TYPE,'T','TABLE','V','VIEW','S','SEQ') TABLE_TYPE
         , T.TABLE_ID
         , T.TABLE_OID
         --, M.TAB_NAME
      FROM SYSTEM_.SYS_USERS_ U
         , SYSTEM_.SYS_TABLES_ T 
           --LEFT OUTER JOIN MIG.TBMAP_TABLIST M ON M.DATA_TYPE = 'T' AND M.TAB_ID = T.TABLE_NAME
     WHERE 1=1
       AND U.USER_NAME LIKE NVL(A_USER_NANE, 'US_%OWN')
       AND U.USER_ID = T.USER_ID
       AND T.TABLE_NAME LIKE UPPER(A_TABLE_NAME)
       AND T.TABLE_TYPE = 'T'
    ORDER BY T.TABLE_NAME
    ;

BEGIN

    -- V_LEN15 := CASE2( V_LEN15>15, 15, V_LEN15 );
    --V_LEN15 := 15;
    V_LEN15 := 30;
    V_LEN05 := 5;
    V_LEN14 := 14;

    OPEN C1;

    SYSTEM_.PRINTLN( RPAD('OWNER',V_LEN14)||' '||RPAD('TABLE_NAME',V_LEN15)||'  '||LPAD('CNT',V_LEN14) );
    SYSTEM_.PRINTLN( RPAD('-',100,'-') );

    V_CNT := 0;
    V_CNT_TB_SUM := 0;
    LOOP

        FETCH C1 INTO V_USER_NAME, V_TABLE_NAME, V_TABLE_TYPE, V_TABLE_ID, V_TABLE_OID
        --, V_KOR_NM
        ;
        EXIT WHEN C1%NOTFOUND;

        IF V_TABLE_TYPE = 'TABLE' THEN

            -- # COUNT
            V_SQL := 'SELECT COUNT(*) FROM '||V_USER_NAME||'.'||V_TABLE_NAME;
            EXECUTE IMMEDIATE V_SQL INTO V_CNT_TB;
        END IF;

        IF V_CNT_TB >= A_CHK_CNT THEN
            IF A_CHK_CNT = -1 AND V_CNT_TB != 0 THEN
                NULL;
            ELSE
                V_CNT := V_CNT + 1;
                V_CNT_TB_SUM := V_CNT_TB_SUM + V_CNT_TB;
                SYSTEM_.PRINTLN(
                    RPAD(V_USER_NAME,V_LEN14)||' '||
                    RPAD(V_TABLE_NAME,V_LEN15)||'  '||
                    LPAD(TRIM(TO_CHAR(V_CNT_TB,'999,999,999,999')),V_LEN14) 
                    --|| '  '||V_KOR_NM 
                );
            END IF;
        END IF;

    END LOOP;

    CLOSE C1;

    SYSTEM_.PRINTLN( RPAD('-',100,'-') );
    SYSTEM_.PRINTLN(RPAD('Total Count',V_LEN15)||'  '||LPAD(TRIM(TO_CHAR(V_CNT_TB_SUM,'999,999,999,999')),V_LEN14));
    SYSTEM_.PRINTLN( V_CNT||' rows selected.' );
END;
/

GRANT EXECUTE ON SYS.SP_TABLE_CNT TO PUBLIC;
