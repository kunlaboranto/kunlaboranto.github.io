prompt  ========  Top 10 SQL Ordered by Elapsed Time =========

SELECT * FROM
(
    SELECT SYSDATE
         --, (SELECT USERNAME FROM ALL_USERS WHERE USER_ID = PARSING_USER_ID ) USERNAME
         , DECODE( S.SQL_ID, NULL, '0', '1' )                           "R"         -- EXECUTE_FLAG
         , SA.EXECUTIONS
         --, SA.PARSE_CALLS -- TODO: [OKT] Why High ?
         , ROUND(SA.ELAPSED_TIME/1000000,3)                             ETIME_SUM   -- "ELAPSED_TIME(S)"
         , ROUND(SA.ELAPSED_TIME/EXECUTIONS/1000000,3)                  ETIME       -- "ELAP/EXEC(S)"
         , ROUND(SA.CPU_TIME/EXECUTIONS/1000000,3)                      CPU_TIME
         --, ROUND((SA.ELAPSED_TIME - SA.CPU_TIME)/EXECUTIONS/1000000,3)  WTIME
         --, ROUND(SA.USER_IO_WAIT_TIME/EXECUTIONS/1000000,3)             USER_IO_WAIT_TIME
         , ROUND(SA.BUFFER_GETS/SA.EXECUTIONS,1)                        GETS        -- "GETS/EXEC"
         , ROUND(SA.PHYSICAL_READ_REQUESTS/SA.EXECUTIONS,3)             PGETS       -- "P-GETS/EXEC"
         --, ROUND(SA.PHYSICAL_READ_BYTES/SA.EXECUTIONS,3)              PGETS_B     -- "P-GETS-B/EXEC"
         , CASE WHEN SA.PHYSICAL_READ_REQUESTS = 0
                THEN -1
                ELSE ROUND(SA.PHYSICAL_READ_BYTES/SA.PHYSICAL_READ_REQUESTS/1024,0)    
            END                                                         PGETS_KB    -- "P-GETS-B/EXEC"
         , CASE WHEN SA.BUFFER_GETS = 0
                THEN -1
                ELSE ROUND(SA.PHYSICAL_READ_BYTES*100/8192/SA.BUFFER_GETS,3)
            END                                                         MISS
         , ROUND(SA.ROWS_PROCESSED/SA.EXECUTIONS,1)                     "ROWS"
         , RPAD( SA.MODULE, 20 )                                        MODULE
         --, SA.HASH_VALUE
         , SA.SQL_ID
/*
        -- TBR-10073: Response time for the global view exceeded threshold.   
         , CASE WHEN S.SQL_ID IS NULL 
                THEN NULL
                ELSE (SELECT SQL_CHILD_NUMBER||'' FROM GV$SESSION S1 WHERE S1.SQL_ID = SA.SQL_ID AND ROWNUM = 1 )
            END CHILD_NUMBER
*/
         --, LENGTHB( SA.SQL_TEXT ) AS LEN
         , LPAD( LENGTHB( SA.SQL_TEXT ), 4) ||'> '|| RPAD(REPLACE(REPLACE(REPLACE(REPLACE( SA.SQL_TEXT, CHR(10), ' '),CHR(9),' '),'	',' '),'  ',' '),160)||CHR(10) QRY
      FROM GV$SQLAREA SA
           LEFT OUTER JOIN ( SELECT DISTINCT SQL_ID FROM GV$SESSION WHERE STATUS = 'RUNNING' ) S
                   ON S.SQL_ID = SA.SQL_ID
     WHERE 1=1
       AND SA.ELAPSED_TIME > 0
       AND SA.EXECUTIONS > 0
       --AND SA.MODULE NOT LIKE '%Orange%'
     --ORDER BY SA.ELAPSED_TIME DESC
     ORDER BY DECODE( S.SQL_ID, NULL, 0, 1 ) DESC, SA.ELAPSED_TIME DESC
)
 WHERE 1=1
   --AND ROWNUM <= 10
   AND ROWNUM <= 15
   --AND ROWNUM <= 20
   --AND ROWNUM <= 100
/
