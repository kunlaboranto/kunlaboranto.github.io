CREATE OR REPLACE VIEW US_GDMON.GDR_VW_LONG_RUN_QUERY_EVENT
--CREATE VIEW US_GDMON.GDR_VW_LONG_RUN_QUERY_EVENT
AS
SELECT ROWNUM RANK
     , RS.*
  FROM (
        SELECT DB_USERNAME USER_NAME
             , DECODE( EVENT, 'no wait event', 'X', EVENT ) EVENT
             , UX2DATE(LAST_QUERY_START_TIME) SQL_EXEC_START
             , ROUND(TOTAL_TIME  /1000/1000,3) TOTAL_TIME
             , ROUND(EXECUTE_TIME/1000/1000,3) EXECUTE_TIME
             , ROUND(FETCH_TIME  /1000/1000,3) FETCH_TIME
             , ROUND(WAIT_TIME  /1000/1000,3) WAIT_TIME
             , DECODE(IDLE_START_TIME, 0, 0, DATE2UX(SYSDATE) - IDLE_START_TIME) IDLE_TIME
             , EXECUTE_SUCCESS EXECUTES
             , GET_PAGE
             , READ_PAGE
             , CREATE_PAGE                 
             , CASE WHEN COMM_NAME LIKE 'TCP %' THEN SUBSTR( COMM_NAME, 5, INSTR( COMM_NAME, ':' ) - 5 ) ELSE 'localhost' END MACHINE
             , DECODE( INSTR( COMM_NAME, ':' ), 0, 0, SUBSTR( COMM_NAME, INSTR( COMM_NAME, ':' ) + 1, 10 ) ) PORT
             , CASE WHEN CLIENT_TYPE LIKE 'CLI%' THEN CLIENT_PID ELSE NULL END SPID                 
             , NVL(CLIENT_APP_INFO,'X') AS MODULE
             , X.DUP_CNT
             , CASE WHEN ( UPPER( SUBSTR(QUERY,1,64) ) NOT LIKE '%INSERT%' AND MEM_CURSOR_FULL_SCAN + DISK_CURSOR_FULL_SCAN > 0 )
                     THEN 1
                     ELSE 0
                END AS IS_FULLSCAN
             , SESSION_ID SID
             , CURRENT_STMT_ID STMT_ID
             , DECODE( SQL_CACHE_TEXT_ID, 'NO_SQL_CACHE_STMT', 'X', SQL_CACHE_TEXT_ID ) SQL_CACHE_TEXT_ID
             , NVL( 
                CASE WHEN GDR_SF_XLOG_NAME(QUERY) IS NULL 
                     THEN TRIM( ( SELECT XLOG_NAME FROM GD$SQL_PLAN PL WHERE ST.SQL_CACHE_TEXT_ID <> 'NO_SQL_CACHE_STMT' AND PL.FIRST_SQL_CACHE_TEXT_ID = ST.SQL_CACHE_TEXT_ID LIMIT 1) )
                     ELSE GDR_SF_XLOG_NAME(QUERY)
                 END
                , 'X') XLOG_NAME
             --, RTRIM(RPAD(REPLACE2(REPLACE2(REPLACE2(REPLACE2(QUERY,CHR(10),' '),CHR(9),' '),'    ',' '),'  ',' '), 1000))||CHR(10) QRY
             , TRIM(RPAD(
REPLACE2
(
    REPLACE2 
    ( 
        REPLACE2
        (
            REPLACE2
            (
                REPLACE2
                (
                    REPLACE2
                    (
                        REPLACE2
                        (
                            REPLACE2(REPLACE2(QUERY,CHR(10),' '),CHR(13),' '),CHR(9),' '
                        ),'        ',' '
                    ),'    ',' '
                ),'   ',' '
            ),'  ',' '
        ),'  ',' '
    )
    ,' ,',','
)
             --, 16000)) AS QRY
             , 16000 - 5334)) AS QRY
             , NVL( ( SELECT SQL_TEXT FROM GD$SQL_PLAN PL WHERE ST.SQL_CACHE_TEXT_ID <> 'NO_SQL_CACHE_STMT' AND PL.FIRST_SQL_CACHE_TEXT_ID = ST.SQL_CACHE_TEXT_ID LIMIT 1) , QUERY) SQL_TEXT
             , UX2DATE(FETCH_START_TIME) FETCH_START_TIME
             , UX2DATE(IDLE_START_TIME) IDLE_START_TIME
             , UX2DATE(LOGIN_TIME) LOGIN_TIME
          FROM V$STATEMENT ST
               INNER JOIN V$SESSION SS 
                       ON SS.ID = ST.SESSION_ID AND SS.CURRENT_STMT_ID = ST.ID
               INNER JOIN (SELECT MIN(LAST_QUERY_START_TIME||','||SESSION_ID||','||CURRENT_STMT_ID) XPK, COUNT(*) DUP_CNT
                             FROM V$STATEMENT ST
                                  INNER JOIN V$SESSION SS ON SS.ID = ST.SESSION_ID AND SS.CURRENT_STMT_ID = ST.ID AND SS.DB_USERID > 10
                            WHERE EXECUTE_FLAG = 1
                            GROUP BY DB_USERNAME, EVENT, CLIENT_APP_INFO, SQL_CACHE_TEXT_ID, LENGTHB( QUERY ) 
                          ) X
                       ON X.XPK = LAST_QUERY_START_TIME||','||SESSION_ID||','||CURRENT_STMT_ID
         WHERE 1=1
         ORDER BY DUP_CNT DESC, EXECUTE_TIME DESC, TOTAL_TIME DESC
         LIMIT 200
       ) RS;
