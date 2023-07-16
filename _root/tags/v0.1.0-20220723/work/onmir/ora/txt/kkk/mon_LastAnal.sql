set trimout ON
set trimspool on
set pagesize 2000
set linesize 2000

col owner form a20
col index_owner form a20
col table_owner form a20
col TABLE_NAME form a40
col INDEX_NAME form a40

spool checkstat.lst

PROMPT Regular Tables

select owner,table_name,last_analyzed, global_stats
from dba_tables
where owner not in ('SYS', 'SYSTEM' , 'OUTLN' , 'DIP' , 'TSMSYS' , 'DBSNMP' , 'ORACLE_OC' , 'WMSYS' , 'SYSMAN', 'XDB')
order by owner,table_name
;

PROMPT Partitioned Tables

select table_owner, table_name, partition_name, last_analyzed, global_stats
from dba_tab_partitions
where table_owner not in ('SYS', 'SYSTEM' , 'OUTLN' , 'DIP' , 'TSMSYS' , 'DBSNMP' , 'ORACLE_OC' , 'WMSYS' , 'SYSMAN', 'XDB')
order by table_owner,table_name, partition_name
;

PROMPT Regular Indexes

select owner, index_name, last_analyzed, global_stats
from dba_indexes
where owner not in ('SYS', 'SYSTEM' , 'OUTLN' , 'DIP' , 'TSMSYS' , 'DBSNMP' , 'ORACLE_OC' , 'WMSYS' , 'SYSMAN', 'XDB')
order by owner, index_name
;

PROMPT Partitioned Indexes

select index_owner, index_name, partition_name, last_analyzed, global_stats
from dba_ind_partitions
where index_owner not in ('SYS', 'SYSTEM' , 'OUTLN' , 'DIP' , 'TSMSYS' , 'DBSNMP' , 'ORACLE_OC' , 'WMSYS' , 'SYSMAN', 'XDB')
order by index_owner, index_name, partition_name
;

spool off
