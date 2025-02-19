CREATE OR REPLACE VIEW US_GDMON.ALL_IND_COLUMNS AS
SELECT 
       U2.USER_NAME INDEX_OWNER
     , I.INDEX_NAME
     , U.USER_NAME TABLE_OWNER
     , T.TABLE_NAME
     , C.COLUMN_NAME
     , IC.INDEX_COL_ORDER + 1 COLUMN_POSITION
     , SF_COL_TYPE( C.DATA_TYPE, C.PRECISION, C.SCALE ) DATA_TYPE
     , DECODE(SORT_ORDER,'A','ASC','D','DESC') DESCEND
  FROM SYSTEM_.SYS_TABLES_ T
       INNER JOIN SYSTEM_.SYS_USERS_ U
               ON T.USER_ID = U.USER_ID
       INNER JOIN SYSTEM_.SYS_INDICES_ I
               ON I.TABLE_ID = T.TABLE_ID
       INNER JOIN SYSTEM_.SYS_USERS_ U2
               ON I.USER_ID = U2.USER_ID
       INNER JOIN SYSTEM_.SYS_INDEX_COLUMNS_ IC
               ON IC.INDEX_ID = I.INDEX_ID          -- [TODO] Need " INDEX_ID + SORT_ORDER " Index for Ordering
       INNER JOIN SYSTEM_.SYS_COLUMNS_ C
               ON C.COLUMN_ID = IC.COLUMN_ID
 WHERE 1=1
   AND T.TABLE_TYPE = 'T'
   AND T.USER_ID != 1
   --AND U.USER_NAME LIKE '%OWN'
 --ORDER BY T.TABLE_NAME, I.INDEX_NAME, IC.INDEX_COL_ORDER
;

CREATE PUBLIC SYNONYM ALL_IND_COLUMNS FOR US_GDMON.ALL_IND_COLUMNS ;
GRANT SELECT ON US_GDMON.ALL_IND_COLUMNS TO PUBLIC;



CREATE OR REPLACE VIEW US_GDMON.USER_IND_COLUMNS AS
SELECT * 
  FROM US_GDMON.ALL_IND_COLUMNS
 WHERE 1=1
   AND ( 1=0
      OR INDEX_OWNER = USER_NAME()
      OR TABLE_OWNER = USER_NAME()
       )
;
CREATE PUBLIC SYNONYM USER_IND_COLUMNS FOR US_GDMON.USER_IND_COLUMNS ;
