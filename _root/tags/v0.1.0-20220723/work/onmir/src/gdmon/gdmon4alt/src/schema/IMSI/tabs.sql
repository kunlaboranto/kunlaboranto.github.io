CREATE OR REPLACE VIEW TABS AS
select T.TABLE_NAME TNAME
     , T.TABLE_TYPE TABTYPE
     , T.CREATED
     , T.LAST_DDL_TIME
     --, u.user_name  owner
  from SYSTEM_.SYS_TABLES_ T
     , SYSTEM_.SYS_USERS_ U
 where 1=1
   and T.USER_ID = U.USER_ID
   and U.USER_NAME = USER_NAME()
 UNION ALL
select T.SYNONYM_NAME
     , 'S'
     , T.CREATED
     , T.LAST_DDL_TIME
     --, u.user_name  owner
  from SYSTEM_.SYS_SYNONYMS_ T
     , SYSTEM_.SYS_USERS_ U
 where 1=1
   and T.SYNONYM_OWNER_ID = U.USER_ID
   and U.USER_NAME = USER_NAME()
 order by TNAME
;
