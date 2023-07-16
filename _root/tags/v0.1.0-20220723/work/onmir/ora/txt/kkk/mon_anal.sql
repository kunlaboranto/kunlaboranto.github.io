set trimout ON
set trimspool on
set pagesize 2000
set linesize 2000

col owner form a20
col index_owner form a20
col table_owner form a20
col TABLE_NAME form a40
col INDEX_NAME form a40

SELECT OWNER
     , TABLE_NAME
     , NULL INDEX_NAME
     , LAST_ANALYZED
     , GLOBAL_STATS
  FROM DBA_TABLES
 WHERE 1=1
   AND OWNER NOT IN ('SYS' , 'SYSTEM' , 'OUTLN' , 'DIP' , 'TSMSYS' , 'DBSNMP' , 'ORACLE_OC' , 'WMSYS' , 'SYSMAN' , 'XDB')
   AND TABLE_NAME IN ( 'xx' )
 UNION ALL
SELECT OWNER
     , TABLE_NAME
     , INDEX_NAME
     , LAST_ANALYZED
     , GLOBAL_STATS
  FROM DBA_INDEXES
 WHERE 1=1
   AND OWNER NOT IN ('SYS' , 'SYSTEM' , 'OUTLN' , 'DIP' , 'TSMSYS' , 'DBSNMP' , 'ORACLE_OC' , 'WMSYS' , 'SYSMAN' , 'XDB')
   AND TABLE_NAME IN ( 'xx' )
 ORDER BY OWNER, TABLE_NAME, INDEX_NAME
;
