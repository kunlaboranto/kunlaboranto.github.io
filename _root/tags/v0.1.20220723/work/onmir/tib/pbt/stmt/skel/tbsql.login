set echo off;
set feedback off;
set heading off;
--------------------
-- PRE
--------------------

set linesize 300;
set pagesize 1000;
set long 1000000;
set long 8000000;
--set autot on exp stat planstat;


col SYSDATE format a20
col " " format a40
col VAL format a40
col V10 format a10
col V20 format a20
col V30 format a30
col TNAME format a30
col USERNAME format a30
--col VALUE format a40

col PROG_NAME format a60
col ERROR_MESSAGE format a80
col ERROR_LINE format a4                                                                            
col ERROR_DATE format a20

col "DESC" format a80
col "SQL" format a120

--------------------
-- MAIN
--------------------
@sid
!echo "--"
!echo ""

set feedback on;
set heading on;
set timing on;
--show user

set echo on;
set time on;

--set autot on stat
--@on

set timing off;

    --alter session set optimizer_dynamic_sampling = 0;
    alter session set statistics_level = 'ALL';
    --select * from table( dbms_xplan.display_cursor( format => 'ALLSTATS LAST ALL' ) );

set timing on;


