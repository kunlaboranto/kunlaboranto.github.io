set timing off;

alter session set FETCH_TIMEOUT = 0;
alter session set QUERY_TIMEOUT = 0;
alter session set UTRANS_TIMEOUT = 0;
--alter session set DDL_TIMEOUT = 0;
--alter session set DDL_LOCK_TIMEOUT = 3600;

select sysdate, user_name()||', SID='||session_id() from dual;
set timing on;

