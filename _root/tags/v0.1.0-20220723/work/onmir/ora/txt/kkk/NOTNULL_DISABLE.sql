SET LINESIZE 300;
SET PAGESIZE 0;
COL SQL FORMAT a300;

COL SPOOLNAME NEW_VAL SPOOLNAME;
SELECT 'NOTNULL_DISABLE.sql.out_'||TO_CHAR(SYSDATE,'YYYYMMDD_HH24MISS') SPOOLNAME FROM DUAL;

spool &SPOOLNAME

SELECT 'ALTER TABLE '||COL.OWNER||'.'||COL.TABLE_NAME||' DROP CONSTRAINT '||COL.CONSTRAINT_NAME||';' SQL
     --, CST.*
  FROM ALL_CONSTRAINTS CST
     , ALL_CONS_COLUMNS COL
 WHERE 1=1
   --AND COL.TABLE_NAME = 'TB_COD_9210NT'
   --AND COL.COLUMN_NAME = 'CTPRVN_NM'
   AND COL.OWNER = CST.OWNER
   AND COL.TABLE_NAME = CST.TABLE_NAME   
   AND COL.CONSTRAINT_NAME = CST.CONSTRAINT_NAME   
   AND CST.CONSTRAINT_TYPE = 'C'
   AND CST.CONSTRAINT_NAME LIKE 'SYS_C%'
   AND COL.OWNER LIKE '%ADM'
   AND (COL.TABLE_NAME, COL.COLUMN_NAME) NOT IN ( SELECT TABLE_NAME, COLUMN_NAME FROM ALL_CONS_COLUMNS@IRM100 WHERE OWNER LIKE '%ADM' AND CONSTRAINT_NAME LIKE 'SYS_C%' )
 ORDER BY 1
;

spool off
quit
