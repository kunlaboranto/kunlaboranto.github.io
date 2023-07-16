col V10 format a10;

--select sysdate, sys_context( 'userenv', 'serial#') from dual; -- (X)
--select sysdate, sys_context( 'userenv', 'sid') from dual;
--select sysdate, sys_context( 'userenv', 'sid'), max(sid), min(sid), max(serial#), min(serial#) from v$session;

SELECT SYSDATE
     , SYS_CONTEXT( 'USERENV', 'SID') V10
     , MAX(SID)
     , MIN(SID)
     , MAX(SERIAL#)
     , MIN(SERIAL#)
     , COUNT(DISTINCT SID) SID_C
     , COUNT(DISTINCT SERIAL#) SERIAL_C
     , COUNT(DISTINCT AUDSID) AUDSID_C
     , COUNT(*)
  FROM V$SESSION A
;

SELECT LOGON_TIME
     , SID
     , SERIAL#
     , AUDSID
     , SCHEMANAME
     , SQL_ID
     --, A.*
  FROM V$SESSION A
 WHERE 1=1
   --AND SCHEMANAME = 'US_GDMON' 
   --AND LOGON_TIME > SYSDATE - 1/24
   AND SID = SYS_CONTEXT( 'USERENV', 'SID') 
 ORDER BY A.LOGON_TIME DESC
;
