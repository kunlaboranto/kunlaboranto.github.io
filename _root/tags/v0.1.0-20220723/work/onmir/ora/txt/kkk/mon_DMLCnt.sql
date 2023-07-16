select /*+ ALL_ROWS */ 
to_char(b.timestamp,'yyyy/mm/dd') SNAPTIME
--, a.owner
--, a.table_name
--, b.partition_name
--, b.subpartition_name
, sum(b.inserts) as inserts
, sum(b.updates) as updates
, sum(b.deletes) as deletes
--, b.timestamp
--, b.truncated
, sum(b.inserts + b.updates + b.deletes) as DML
from sys.dba_tables a, sys.dba_tab_modifications b 
where a.owner = b.table_owner(+) 
and a.table_name = b.table_name(+) 
and a.owner not in ('ASTOM','DBSNMP','DBWINE','DIP','EXFSYS','ORACLE_OCM','ORANGE','OUTLN','SYS','SYSMAN','SYSTEM','TSMSYS','WMSYS') 
and a.monitoring = 'YES'
and b.timestamp >= trunc(sysdate-17)
group by to_char(b.timestamp,'yyyy/mm/dd') --, a.owner
order by 1,2;
