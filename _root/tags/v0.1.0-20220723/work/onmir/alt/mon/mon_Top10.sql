SET LINESIZE 340;
SET COLSIZE 0;
--SET VERTICAL ON;

SELECT
       ROUND(EXECUTE_TIME/1000/1000,3) EXECUTE_TIME
     , ROUND(FETCH_TIME/1000/1000,3) FETCH_TIME
     , ROUND(TOTAL_TIME/1000/1000,3) TOTAL_TIME
     , EXECUTE_FLAG
     , 'EXEC SP_SQLTEXT('||SESSION_ID||','||ID||');' SID
     , RPAD(REPLACE2(REPLACE2(REPLACE2(REPLACE2(QUERY,CHR(10),' '),CHR(9),' '),'        ',' '),'  ',' '),110)||CHR(10) QRY
       --QUERY
  FROM V$STATEMENT
 WHERE 1=1
   -- 현재 실행중인 것만 조회
   AND EXECUTE_FLAG = 1
   --AND upper(QUERY) not like 'SELECT%'
   --AND upper(QUERY) not like 'INSERT%'
   --AND upper(QUERY) like '%DELETE%'
   --and session_id not in (select id from v$session c where c.client_app_info like '%Orange%')
 ORDER BY EXECUTE_TIME DESC, EXECUTE_FLAG DESC
 LIMIT 420
;
