SET NEWPAGE 0;
SET SPACE 0;
SET LINESIZE 2000;
SET PAGESIZE 0;
SET ECHO OFF;
SET FEEDBACK OFF;
SET HEADING OFF;
SET TERM OFF;
SET TRIMSPOOL ON;
SET TIMING OFF;
SET RECSEP OFF;
--SET RECSEPCHAR @;
ALTER SESSION SET NLS_DATE_FORMAT='YYYY/MM/DD HH24:MI:SS';
spool OKT_PARAMETER_12GR2.dat
SELECT
'"'||NUM
||'","'||NAME
||'","'||TYPE
||'","'||VALUE
||'","'||DISPLAY_VALUE
||'","'||DEFAULT_VALUE
||'","'||ISDEFAULT
||'","'||ISSES_MODIFIABLE
||'","'||ISSYS_MODIFIABLE
||'","'||ISPDB_MODIFIABLE
||'","'||ISINSTANCE_MODIFIABLE
||'","'||ISMODIFIED
||'","'||ISADJUSTED
||'","'||ISDEPRECATED
||'","'||ISBASIC
||'","'||DESCRIPTION
||'","'||UPDATE_COMMENT
||'","'||HASH
||'","'||CON_ID||'"
'
FROM OKT_PARAMETER_12GR2;
spool off;
exit ;
