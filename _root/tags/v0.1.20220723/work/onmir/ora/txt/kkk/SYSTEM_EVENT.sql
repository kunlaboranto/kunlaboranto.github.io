set pagesize 1000;

col EVENT format a40;
col WAIT_CLASS format a15;

WITH WX AS 
(
SELECT SUM(TIME_WAITED) SUM_TIME_WAITED
  FROM V$SYSTEM_EVENT
 WHERE 1=1
   AND WAIT_CLASS NOT IN ('Idle', 'System I/O', 'Network', 'Administrative')
   AND EVENT NOT IN ('enq: TX - row lock contention', 'xx' )
)
SELECT SYSDATE
     , ROUND(TIME_WAITED * 100 / WX.SUM_TIME_WAITED,2) PCT
     , A.*
  FROM WX
     , V$SYSTEM_EVENT A
 WHERE 1=1
   --AND WAIT_CLASS NOT IN ('Idle', 'System I/O', 'Network', 'Administrative')
   AND EVENT NOT IN ('enq: TX - row lock contention', 'xx' )
   AND EVENT LIKE '%buff%'
   --AND TIME_WAITED * 100 / WX.SUM_TIME_WAITED > 0.01
 ORDER BY A.TIME_WAITED DESC ;
 
