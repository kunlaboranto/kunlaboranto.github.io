set linesize 200;
SELECT 
       SYSDATE
     , 'DB_EFFICIENCY' AS DB_EFFICIENCY 
     , round(sum(decode(METRIC_NAME, 'Database Wait Time Ratio', value)),2) AS DATABASE_WAIT_TIME_RATIO
     , round(sum(decode(METRIC_NAME, 'Database CPU Time Ratio', value)),2) AS DATABASE_CPU_TIME_RATIO
  FROM SYS.V_$SYSMETRIC 
 WHERE METRIC_NAME IN ('Database CPU Time Ratio', 'Database Wait Time Ratio') 
   AND INTSIZE_CSEC = (SELECT max(INTSIZE_CSEC) FROM SYS.V_$SYSMETRIC)
;
