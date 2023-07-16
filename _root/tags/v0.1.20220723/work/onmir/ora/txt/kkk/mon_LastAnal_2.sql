set pagesize 10000

prompt ======================================
prompt ANALYZE - DATE - REGULAR TABLES
prompt ======================================
 
col owner format a20
prompt
select owner,'Tables',trunc(LAST_ANALYZED),count(*)
from dba_tables
where owner not in ('SYS','SYSTEM')
group by owner,'Tables',trunc(LAST_ANALYZED)
/
prompt
prompt ======================================
prompt ANALYZE - DATE - PARTITINED TABLES
prompt ======================================
prompt
select table_owner, 'Partitioned Tables',trunc(last_analyzed), count(*)
from dba_tab_partitions
where table_owner not in ('SYS','SYSTEM')
group by table_owner, 'Partitioned Tables',trunc(last_analyzed)
/
prompt
prompt ======================================
prompt ANALYZE - DATE - REGULAR INDEXES
prompt ======================================
prompt
select owner, 'Regular Indexes', trunc(last_analyzed), count(*)
from dba_indexes
where owner not in ('SYS','SYSTEM')
group by  owner, 'Regular Indexes', trunc(last_analyzed)
/
prompt
prompt ======================================
prompt ANALYZE - DATE - PARTITINED INDEXES
prompt ======================================
prompt
select index_owner, 'Partitioned Indexes',trunc(last_analyzed), count(*)
from dba_ind_partitions
where index_owner not in ('SYS','SYSTEM')
group by  index_owner, 'Partitioned Indexes',trunc(last_analyzed)
/
