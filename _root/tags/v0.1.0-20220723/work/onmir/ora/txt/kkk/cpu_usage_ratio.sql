select /*+ LEADING(u) USE_HASH(u s) */s.sql_id,
       u.username ,
       MODULE ,
       address,
       hash_value ,
       RANK() OVER (
        ORDER BY CPU_TIME DESC) cpu_usage_rank ,
       rank() over(
        order by round(decode(executions, null, 0, 0, 0, (nvl(buffer_gets, 0)/executions)), 1) desc) bgetexrank ,
       rank() over(
        order by EXECUTIONS desc) exrank ,
       trunc( nvl(ratio_to_report(CPU_TIME) over (), 0)*100 , 2) cpu_usage_ratio ,
       sql_text
--, getfullsql(address,hash_value) SQL_FULL_TEXT

--, get_sqlplan2(hash_value,child_number) sql_plan
       ,
       round(decode(executions, null, 0, 0, 0, (nvl(buffer_gets, 0)/executions)), 1) BUFGETSPEREXEC ,
       round(decode(executions, null, 0, 0, 0, (nvl(ELAPSED_TIME, 0)/executions)/ 1000000), 5) ELAPSED_PER_EXEC ,
       round(decode(executions, null, 0, 0, 0, (nvl(CPU_TIME, 0)/executions)/ 1000000), 5) CPU_PER_EXEC ,
       round(decode(executions, null, 0, 0, 0, ((nvl(ELAPSED_TIME, 0) - nvl(CPU_TIME, 0))/executions)/ 1000000), 5) WAIT_PER_EXEC ,
       round(decode(executions, null, 0, 0, 0, (nvl(ROWS_PROCESSED, 0)/executions)), 1) ROWS_PER_EXEC ,
       EXECUTIONS,
       PARSE_CALLS,
       ELAPSED_TIME,
       CPU_TIME,
       DISK_READS,
       BUFFER_GETS,
       ROWS_PROCESSED ,
       SHARABLE_MEM,
       PERSISTENT_MEM,
       RUNTIME_MEM,
       MODULE,
       USERS_EXECUTING ,
       SORTS,
       LOADED_VERSIONS,
       OPEN_VERSIONS,
       USERS_OPENING,
       LOADS,
       FIRST_LOAD_TIME ,
       INVALIDATIONS,
       COMMAND_TYPE,
       OPTIMIZER_MODE,
       OPTIMIZER_COST,
       PARSING_USER_ID ,
       PARSING_SCHEMA_ID,
       KEPT_VERSIONS,
       TYPE_CHK_HEAP,
       HASH_VALUE,
       CHILD_NUMBER ,
       MODULE_HASH,
       ACTION,
       ACTION_HASH,
       SERIALIZABLE_ABORTS,
       OUTLINE_CATEGORY
from   dba_users u,
       v$sql s
where  s.parsing_user_id = u.user_id
and    s.parsing_user_id > 5
and    EXECUTIONS > 10
and    round(decode(executions, null, 0, 0, 0, (nvl(ELAPSED_TIME, 0)/executions)/ 1000000), 5) > 0
and    u.username not in ('DBSNMP',
               'ORACLE_OCM',
               'SYSMAN')
and    ( ( UPPER(MODULE) not like 'TOAD%'
                and    UPPER(MODULE) not like 'T.O.A.D%'
                and    UPPER(MODULE) not like 'SQL DEV%'
                and    UPPER(MODULE) not like 'ORANGE%'
                and    UPPER(MODULE) not like 'GOLDEN%'
                and    UPPER(MODULE) not like 'PL/SQL%'
                and    UPPER(MODULE) not like 'DATA PUMP%'
                and    UPPER(MODULE) not like 'SQLPLUS%'
                and    UPPER(MODULE) not like 'SQL*PLUS%'
                and    UPPER(MODULE) not like 'MANAGER%'
                and    UPPER(MODULE) not like 'DBMS_SCHEDULER%'
                and    UPPER(MODULE) not like 'IMP%'
                and    UPPER(MODULE) not like 'EXP%'
                and    UPPER(MODULE) not like '%IMPEXP%'
                and    UPPER(MODULE) not like 'GEN%'
                and    UPPER(MODULE) not like 'GOLDVW%'
                and    UPPER(MODULE) not like 'ORASCOPE%'
                and    UPPER(MODULE) not like 'TYS_META%'
                and    UPPER(MODULE) not like 'XMONITOR%'
                and    UPPER(MODULE) not like 'ENCORE%'
                and    UPPER(MODULE) not like 'FRMBLD%'
                and    UPPER(MODULE) not like 'EXCEL%'
                and    UPPER(MODULE) not like 'SQLDEVELOPER%'
                and    UPPER(MODULE) not like 'SQLGATE%' )
        OR     MODULE IS NULL )
ORDER BY cpu_usage_rank;

