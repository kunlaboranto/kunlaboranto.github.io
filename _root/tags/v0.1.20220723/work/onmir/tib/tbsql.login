--set linesize 180;
set pagesize 1000;
set timing on;
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


/*

$ grep ^set ./tbinary/monitor/sql/*.sql |sed -e "s/^.*://g" |sort |uniq -c |sort -k 3
   3 set feed off
 113 set feedback off
   7 set head off
   2 set head on
   2 set lines 132
   4 set linesize 80
   3 set pages 120
  38 set pagesize 100
   2 set serveroutput on

*/
