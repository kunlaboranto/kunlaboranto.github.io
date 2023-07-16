set pagesize 1000;
col NAME format a30;
col VALUE format a20;
col DEFAULT_VALUE format a20;
col SQL_FEATURE format a20;

SELECT --ID,
       NAME
     , VALUE
     , DEFAULT_VALUE
     , ISDEFAULT
     --, SQL_FEATURE
     --, CON_ID
     --, A.*
  FROM V$SYS_OPTIMIZER_ENV A
 WHERE 1=1
   --AND ISDEFAULT != 'YES'
 ORDER BY A.NAME
;
