-- export NLS_DATE_FORMAT="YY/MM/DD"
--set linesize 250 pagesize 0 trims on tab off long 1000000
set linesize 250 pagesize 50000 trims on tab off long 1000000
set linesize 360;

set timing off;

    --alter session set optimizer_dynamic_sampling = 0;
    alter session set statistics_level = 'ALL';
    --select * from table( dbms_xplan.display_cursor( format => 'ALLSTATS LAST ALL' ) );

set timing on;

PROMPT '[NOTE] export NLS_DATE_FORMAT="YY/MM/DD"`
