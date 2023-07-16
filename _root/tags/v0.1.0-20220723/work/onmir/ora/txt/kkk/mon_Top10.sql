SELECT /* DBA_MON */ * FROM (
    SELECT SYSDATE AS DT
         , SA.LAST_LOAD_TIME, SA.LAST_ACTIVE_TIME
         , DECODE( S.SQL_ID, NULL, '0', '1' )                           "R"         -- EXECUTE_FLAG
         , SA.SQL_ID
         --, CASE WHEN S.SQL_ID IS NULL THEN NULL ELSE (SELECT SQL_CHILD_NUMBER||'' FROM V$SESSION S1 WHERE S1.SQL_ID = SA.SQL_ID AND ROWNUM = 1 ) END CHILD_NUMBER
         , ROUND(SA.ELAPSED_TIME/1000000,3)                             ETIME_SUM   -- "ELAPSED_TIME(S)"
         , SA.EXECUTIONS
         , ROUND(SA.ROWS_PROCESSED/SA.EXECUTIONS,0)                     "ROWS"
         , ROUND(SA.ELAPSED_TIME/EXECUTIONS/1000000,3)                  ETIME       -- "ELAP/EXEC(S)"
         , ROUND(SA.CPU_TIME/EXECUTIONS/1000000,3)                      CPU_TIME
         , ROUND(SA.BUFFER_GETS/SA.EXECUTIONS,1)                        GETS        -- "GETS/EXEC"
         , ROUND(SA.PHYSICAL_READ_REQUESTS/SA.EXECUTIONS,3)             PGETS       -- "P-GETS/EXEC"
         , CASE WHEN SA.PHYSICAL_READ_REQUESTS = 0
                THEN -1
                ELSE ROUND(SA.PHYSICAL_READ_BYTES/SA.PHYSICAL_READ_REQUESTS/1024,0)    
            END                                                         PGETS_KB    -- "P-GETS-B/EXEC"
         , CASE WHEN SA.BUFFER_GETS = 0
                THEN -1
                ELSE ROUND(SA.PHYSICAL_READ_REQUESTS*100/SA.BUFFER_GETS,1)
            END                                                         "MISS(%)"
         , RPAD( SA.MODULE, 20 )                                        MODULE
         , LENGTH( SA.SQL_FULLTEXT ) AS LEN
         , SA.SQL_TEXT
      FROM V$SQLAREA SA
           --LEFT OUTER JOIN 
           INNER JOIN 
           ( SELECT DISTINCT SQL_ID FROM V$SESSION WHERE STATUS in ( 'ACTIVE', 'RUNNING' ) ) S
                   ON S.SQL_ID = SA.SQL_ID
     WHERE 1=1
       AND SA.ELAPSED_TIME > 0
/*
       AND SA.EXECUTIONS > 0
       --AND SA.MODULE NOT LIKE '%Orange%'
       AND SA.SQL_TEXT NOT LIKE 'UPDATE%'
       AND SA.SQL_TEXT NOT LIKE 'INSERT%'
       AND SA.SQL_TEXT NOT LIKE '%CALL%'
       AND SA.PHYSICAL_READ_REQUESTS > 0
       AND ( SA.SQL_ID = 'xx'
         OR ( SA.SQL_TEXT LIKE '%OKT_01%'
            AND NOT ( 1=0
                   OR SA.SQL_TEXT LIKE '%DBA_MON%'
                   OR SA.SQL_TEXT LIKE '%xx%'
                    ) 
            )
           )
*/
     ORDER BY DECODE( S.SQL_ID, NULL, 0, 1 ) DESC, SA.ELAPSED_TIME DESC
)
 WHERE 1=1
   AND ROWNUM <= 100
;
