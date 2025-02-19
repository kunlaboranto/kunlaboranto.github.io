CREATE OR REPLACE VIEW US_GDMON.GD_ALL_SEGMENTS AS
SELECT U.USER_NAME OWNER
     , T.TABLE_NAME
     , T.TABLE_NAME SEGMENT_NAME
     , D.SEGMENT_TYPE
     , C.NAME TABLESPACE_NAME
     , CAST( C.EXTENT_PAGE_COUNT * C.PAGE_SIZE * D.EXTENT_TOTAL_COUNT AS BIGINT ) BYTES
     , CAST( ROUND(C.EXTENT_PAGE_COUNT * C.PAGE_SIZE * D.EXTENT_TOTAL_COUNT/1024/1024, 0) AS BIGINT ) MBYTES
     , CAST( ( C.EXTENT_PAGE_COUNT * D.EXTENT_TOTAL_COUNT ) AS BIGINT ) BLOCKS
     , D.EXTENT_TOTAL_COUNT EXTENTS
     , CAST( CASE WHEN D.SEGMENT_TYPE IN ('TABLE') THEN SF_TABLE_CNT( U.USER_NAME||'.'||T.TABLE_NAME ) ELSE -1 END AS BIGINT ) NUM_ROWS
     , T.CREATED
     , T.LAST_DDL_TIME
     --, D.*
  FROM SYSTEM_.SYS_USERS_ U
     , V$TABLESPACES C
     , V$SEGMENT D
       INNER JOIN SYSTEM_.SYS_TABLES_ T ON T.TABLE_OID = D.TABLE_OID AND T.TABLE_TYPE = 'T' AND D.SEGMENT_TYPE = 'TABLE' /* AND T.TABLE_NAME = 'QAA515DT' */
 WHERE 1 = 1
   AND U.USER_ID = T.USER_ID
   AND C.ID = D.SPACE_ID
   AND U.USER_NAME NOT IN ('SYSTEM')
 UNION ALL
SELECT U.USER_NAME OWNER
     , T.TABLE_NAME
     , X.INDEX_NAME SEGMENT_NAME
     , D.SEGMENT_TYPE
     , C.NAME TABLESPACE_NAME
     , CAST( C.EXTENT_PAGE_COUNT * C.PAGE_SIZE * D.EXTENT_TOTAL_COUNT AS BIGINT ) BYTES
     , CAST( ROUND(C.EXTENT_PAGE_COUNT * C.PAGE_SIZE * D.EXTENT_TOTAL_COUNT/1024/1024, 0) AS BIGINT ) MBYTES
     , CAST( ( C.EXTENT_PAGE_COUNT * D.EXTENT_TOTAL_COUNT ) AS BIGINT ) BLOCKS
     , D.EXTENT_TOTAL_COUNT EXTENTS
     , CAST( CASE WHEN D.SEGMENT_TYPE IN ('TABLE') THEN SF_TABLE_CNT( U.USER_NAME||'.'||T.TABLE_NAME ) ELSE -1 END AS BIGINT ) NUM_ROWS
     , X.CREATED
     , X.LAST_DDL_TIME
     --, D.*
  FROM SYSTEM_.SYS_USERS_ U
     , V$TABLESPACES C
     , V$SEGMENT D
       INNER JOIN SYSTEM_.SYS_TABLES_ T ON T.TABLE_OID = D.TABLE_OID AND T.TABLE_TYPE = 'T' /* AND T.TABLE_NAME = 'QAA515DT' */
       INNER JOIN V$INDEX E ON E.INDEX_SEG_PID = D.SEGMENT_PID AND D.SEGMENT_TYPE = 'INDEX' AND E.TABLE_OID = T.TABLE_OID
       INNER JOIN SYSTEM_.SYS_INDICES_ X ON X.TABLE_ID = T.TABLE_ID AND X.INDEX_ID = E.INDEX_ID
 WHERE 1 = 1
   AND U.USER_ID = T.USER_ID
   AND C.ID = D.SPACE_ID
   AND U.USER_NAME NOT IN ('SYSTEM')
 --ORDER BY OWNER, TABLE_NAME, SEGMENT_TYPE DESC, SEGMENT_NAME
;

GRANT SELECT ON US_GDMON.GD_ALL_SEGMENTS TO PUBLIC;
