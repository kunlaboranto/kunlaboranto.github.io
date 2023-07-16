select SQL_ID||'/'||SQL_CHILD_NUMBER from v$session where CLIENT_IDENTIFIER = 'OKT_XP1' and STATUS in ( 'ACTIVE', 'RUNNING' )  ;

