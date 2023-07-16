set echo off
set feedback off
set timing off
set linesize 180
set pagesize 1000

col "Tablespace Name" format a30
col "Bytes(MB)"       format 999,999,999
col "Used(MB)"        format 999,999,999
col "Percent(%)"      format 9999999.99
col "Free(MB)"        format 999,999,999
col "Free(%)"         format 9999.99
col "MaxBytes(MB)"    format 999,999,999


SELECT DDF.TABLESPACE_NAME "Tablespace Name"
     , DDF.BYTES/1024/1024 "Bytes(MB)"
     , (DDF.BYTES - DFS.BYTES)/1024/1024 "Used(MB)"
     , ROUND(((DDF.BYTES - DFS.BYTES)/DDF.BYTES) * 100, 2) "Percent(%)"
     , DFS.BYTES/1024/1024 "Free(MB)"
     , ROUND((1 - ((DDF.BYTES - DFS.BYTES)/DDF.BYTES)) * 100, 2) "Free(%)"
     , ROUND(DDF.MAXBYTES/1024/1024, 0) "MaxBytes(MB)"
  FROM (SELECT TABLESPACE_NAME
             , SUM(BYTES) BYTES
             , SUM( DECODE( MAXBYTES, 0, BYTES, MAXBYTES) ) MAXBYTES
          FROM DBA_DATA_FILES
         GROUP BY TABLESPACE_NAME) DDF
     , (SELECT TABLESPACE_NAME
             , SUM(BYTES) BYTES
          FROM DBA_FREE_SPACE
         GROUP BY TABLESPACE_NAME) DFS
 WHERE DDF.TABLESPACE_NAME = DFS.TABLESPACE_NAME 
--ORDER BY ((ddf.bytes-dfs.bytes)/ddf.bytes) DESC
--ORDER BY 1, ((ddf.bytes-dfs.bytes)/ddf.bytes) DESC
/*
 UNION ALL
SELECT DDF.TABLESPACE_NAME "Tablespace Name"
     , DDF.BYTES/1024/1024 "Bytes(MB)"
     , (DDF.BYTES - DFS.BYTES)/1024/1024 "Used(MB)"
     , ROUND(((DDF.BYTES - DFS.BYTES)/DDF.BYTES) * 100, 2) "Percent(%)"
     , DFS.BYTES/1024/1024 "Free(MB)"
     , ROUND((1 - ((DDF.BYTES - DFS.BYTES)/DDF.BYTES)) * 100, 2) "Free(%)"
     , ROUND(DDF.MAXBYTES/1024/1024, 0) "MaxBytes(MB)"
  FROM (SELECT TABLESPACE_NAME
             , SUM(BYTES) BYTES
             , SUM( DECODE( MAXBYTES, 0, BYTES, MAXBYTES) ) MAXBYTES
          FROM DBA_TEMP_FILES
         GROUP BY TABLESPACE_NAME) DDF
     , (SELECT TABLESPACE_NAME
             , SUM(BYTES_FREE) BYTES
          --FROM DBA_FREE_SPACE
          FROM V$TEMP_SPACE_HEADER
         GROUP BY TABLESPACE_NAME) DFS
 WHERE DDF.TABLESPACE_NAME = DFS.TABLESPACE_NAME 
*/
 ORDER BY 1 
;

set heading off;
--select sysdate, INSTANCE_NAME from V$INSTANCE  ;
select '[ ' || INSTANCE_NAME ||' - '|| TO_CHAR( SYSDATE, 'YYYY/MM/DD HH24:MI:SS' ) ||' ]' from V$INSTANCE  ;

/*
col "Location"        format a45
col "Size(MB)"        format 9,999,999.99
col "MaxSize(MB)"     format 9,999,999.99

SELECT tablespace_name "Tablespace Name",
       file_name "Location" ,
       bytes/1024/1024 "Size(MB)",
       maxbytes/1024/1024 "MaxSize(MB)"
FROM dba_temp_files
;

*/

quit
