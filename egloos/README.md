## xx

```SQL
```


## show_full_processlist-xx

```SQL
$ cat ../skel/show_full_processlist.sql
/*
-- ms-xx -f -vvv < show_full_processlist.sql > ./logs/show_full_processlist.out.ms-xx.`date "+%Y%m%d_%H%M"`.1
*/

show full processlist;

$ cat ../skel/show_full_processlist.sh
#!/bin/sh

 SQLCMD="ms-xx"
test "x$1" != "x" && SQLCMD="$1"

echo ""
echo "[${SQLCMD}]"
echo ""

# ${SQLCMD} -f -vvv < show_full_processlist.sql > ./logs/show_full_processlist.out.${SQLCMD}.`date "+%Y%m%d_%H%M"`.1
${SQLCMD} -f -vvv < show_full_processlist.sql 2>&1 |grep -v "Using a password"  > ./logs/aa.out
cat ./logs/aa.out |dos2unix > ./logs/show_full_processlist.out.${SQLCMD}.`date "+%Y%m%d_%H%M"`.1

MYUSR="X2040811"
echo ""
echo "@@ Running JOB @@"
grep "^|" logs/aa.out |grep -v " 0 | init " |grep -v Sleep |grep -v ${MYUSR}
echo ""
echo "@@ Running JOB (${MYUSR}) @@"
grep ${MYUSR} logs/aa.out |grep -v " 0 | init "

exit

${SQLCMD} -f -vvv < show_full_processlist.sql |dos2unix > ./logs/show_full_processlist.out.${SQLCMD}.`date "+%Y%m%d_%H%M"`.1

```


## mon_sp.sql-xx

```SQL
$ cat ../skel/mon_sp.sql-xx
/*
 # Usage:
    watch -n 10 'ms-xx < mon_sp.sql 2>&1 |dos2unix |grep -v password |expand -t 8 |tee -a watch.log.ms-xx.`date "+%Y%m%d"`'

*/

SELECT
       -- NOW() AS ILSI
       DATE_FORMAT(NOW(),'%d %H:%i:%S') AS SNAP_TIME_
     -- , ID AS "ID      "
     -- 305204400685696 : READ ONLY TX
     -- 1018111834      : TX
     -- NULL            : NO-TX
     -- 33788135 1018111834 : ID + TX
     -- , ( SELECT IFNULL( MAX(TRX_ID), 0 ) AS TRX_ID FROM INFORMATION_SCHEMA.INNODB_TRX WHERE TRX_MYSQL_THREAD_ID = A.ID ) AS TRX_ID
     -- [NOTE] 만일 'x' 가 짤린다면, TRX_ID가 10자리를 넘어선것임
     -- , CONCAT(ID, ' ', ( SELECT LPAD( CONCAT(IFNULL(MAX(TRX_ID),0),'x'),11,' ') AS TRX_ID FROM INFORMATION_SCHEMA.INNODB_TRX WHERE TRX_MYSQL_THREAD_ID = A.ID AND TRX_ID < POWER(2,48) )) AS "ID            TRX_ID"
     , CONCAT(ID, ' ', ( SELECT REPLACE(LPAD( CONCAT(IFNULL(MAX(TRX_ID),0),'x'),11,' '),' 0x',' 0 ') AS TRX_ID FROM INFORMATION_SCHEMA.INNODB_TRX WHERE TRX_MYSQL_THREAD_ID = A.ID AND TRX_ID < POWER(2,48) )) AS "ID            TRX_ID"
     -- , USER
     , SUBSTR(USER,1,7) AS USER
     -- , DB
     -- , COMMAND
     , TIME
     , SUBSTR(STATE,1,5) AS STATE
     -- , HOST
     , SUBSTR(HOST,1,INSTR(HOST,':')-1) AS HOST
     -- , STATEMENT_DIGEST(INFO) AS SQL_HASH
     -- , SUBSTR(STATEMENT_DIGEST_TEXT(INFO),1,60) AS SQL_TEXT
     -- , SUBSTR(INFO,1,86) AS SQL_TEXT
     -- , SUBSTR(INFO,1,180) AS SQL_TEXT
     , SUBSTR(REGEXP_REPLACE(REPLACE(INFO,CHAR(9),' '),' [ ]*',' '),1,180) AS SQL_TEXT
  FROM INFORMATION_SCHEMA.PROCESSLIST A
 WHERE 1=1
   AND USER NOT IN ('event_scheduler')
   AND ID <> connection_id()
   AND Command NOT IN ( 'Sleep' )
   AND STATE NOT IN ( 'Source has sent all binlog to replica; waiting for more updates' ) 
 ORDER BY A.TIME DESC
;

```


## L3.sql-xx

```SQL
$ cat ../skel/L3.sql-xx 
/*
  Usage:
    watch -n 10 'ms-xx < L3.sql 2>&1 |grep -v password |expand -t 16 |tee -a watch.LOCK.log.ms-xx.`date "+%Y%m%d"`'

  BUGBUG:
    if "-- Est DDL TIME" then "Unable to normalize query; Additional details available are Query Text:" AT 'performance_schema.error_log'
*/

/* Est DDL TIME */
SELECT 
       CURRENT_TIME AS TIME
     , ROUND(WORK_COMPLETED*100/WORK_ESTIMATED,1) AS PCT
     , ROUND( (timer_end - timer_start)/10E11, 3 ) as 'ELAP,s'
     , WORK_COMPLETED, WORK_ESTIMATED
     , EVENT_NAME
     -- , NESTING_EVENT_ID 
     -- , ROUND( TIMER_WAIT/10E11, 3 ) as TIMER_WAIT 
     -- , a.* 
FROM performance_schema.events_stages_current a ;
SELECT ' ' FROM DUAL WHERE 1 = (SELECT 1 FROM performance_schema.events_stages_current LIMIT 1);


SELECT NOW() TM4,
       r.trx_id waiting_trx_id
     , r.trx_mysql_thread_id waiting_thread
     , r.trx_query waiting_query
     , b.trx_id blocking_trx_id
     , b.trx_mysql_thread_id blocking_thread
     -- , b.trx_query blocking_query
     , IFNULL( b.trx_query
             , (SELECT SUBSTR( ss.last_statement, 1, 100 ) FROM sys.x$session ss WHERE ss.conn_id = b.trx_mysql_thread_id LIMIT 1) 
             ) AS BLOCKING_QUERY
     , (SELECT 
               CONCAT_WS('','['
               , DATE_FORMAT(DATE_SUB( NOW(), INTERVAL ROUND(ss.trx_latency/10E11,0) SECOND ),'%Y-%m-%d %H:%i:%s') 
               , ' - '
               -- , ss.command
               -- , ss.state
               , IFNULL(ss.state,ss.command)
               , '] ')
          FROM sys.x$session ss WHERE ss.conn_id = b.trx_mysql_thread_id ) AS BLOCKING_TRX_STARTED
  FROM performance_schema.data_lock_waits w 
       INNER JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_engine_transaction_id 
       INNER JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_engine_transaction_id
\G
SELECT ' ' FROM DUAL WHERE 1 = (SELECT 1 FROM sys.schema_table_lock_waits LIMIT 1);

/* NORMAL LOCK */
/* -- {{ OKT
select CURRENT_TIME TM1, w.*, count(*) over() as DATA_LOCK_CNT
     , (select substr( b.trx_query, 1, 100 ) from information_schema.innodb_trx b where b.trx_id = w.blocking_engine_transaction_id) as BLOCKING_QUERY
  from performance_schema.data_lock_waits w where not exists (select 1 from sys.schema_table_lock_waits lw) limit 3 \G
SELECT ' ' FROM DUAL WHERE 1 = (SELECT 1 FROM performance_schema.data_lock_waits LIMIT 1);
*/ -- }} OKT


/* META LOCK */ 
select CURRENT_TIME TM2, lw.*, count(*) over() as META_LOCK_CNT 
     -- , (select substr( convert(px.info using utf8mb4), 1, 131000 ) from INFORMATION_SCHEMA.processlist px where px.id = lw.blocking_pid ) as BLOCKING_QUERY
     -- , (select substr( convert(px.info using utf8mb4), 1, 100    ) from INFORMATION_SCHEMA.processlist px where px.id = lw.blocking_pid ) as BLOCKING_QUERY
     , IFNULL(
               (SELECT SUBSTR( CONVERT(px.info using utf8mb4), 1, 100    ) FROM INFORMATION_SCHEMA.processlist px WHERE px.id = lw.blocking_pid LIMIT 1)
             , (SELECT SUBSTR( ss.last_statement, 1, 100 ) FROM sys.x$session ss WHERE ss.conn_id = lw.blocking_pid LIMIT 1) 
             ) AS BLOCKING_QUERY
     , (SELECT 
               CONCAT_WS('','['
               , DATE_FORMAT(DATE_SUB( NOW(), INTERVAL ROUND(ss.trx_latency/10E11,0) SECOND ),'%Y-%m-%d %H:%i:%s') 
               , ' - '
               -- , ss.command
               -- , ss.state
               , IFNULL(ss.state,ss.command)
               , '] ')
          FROM sys.x$session ss WHERE ss.conn_id = lw.blocking_pid ) AS BLOCKING_TRX_STARTED
  from sys.schema_table_lock_waits lw where waiting_pid <> blocking_pid limit 8 \G
SELECT ' ' FROM DUAL WHERE 1 = (SELECT 1 FROM sys.schema_table_lock_waits LIMIT 1);


```


## prop.sh-xx

```SQL
$ cat prop.sh-xx
#!/bin/sh

MYSQL_PS1=""

 SQLCMD="msl"
test "x$2" != "x" && SQLCMD="$2"

STR="$1"

########################################
# FUNCTION
########################################

alias grep='grep --color=auto'

function doIt
{
    ${SQLCMD} -t -vvv << EOF
   SHOW VARIABLES LIKE '%${STR}%' ;
-- SHOW GLOBAL VARIABLES LIKE '%${STR}%' ;
EOF
}

function doIt_NEW
{
    ${SQLCMD} -s -t -vvv << EOF
SELECT NOW() AS SNAP_TIME, @@version, @@hostname;
SHOW VARIABLES LIKE '%' ;
EOF

# -- SELECT @@hostname, @@aurora_server_id;
# -- SHOW GLOBAL VARIABLES LIKE '%' ;
# -- SHOW GLOBAL STATUS;
}

########################################
# MAIN
########################################

echo ""
echo "[${SQLCMD}]"

#doIt ; exit 

#doIt 2>&1 |expand -t 4 |sed -e "s/|[ ]*$//g" |sed -e "s/ [ ]*$//g" |grep -v "insecure.$" |grep -v ^Bye
#exit

if [ "x${STR}" = "x%" ]
then
    doIt_NEW 2>&1 |dos2unix |expand -t 4 |sed -e "s/-[-]*+$/--------|/g" |sed -e "s/|[ ]*$//g" |sed -e "s/ [ ]*$//g" |tee .prop.TXT.${SQLCMD}
else
    doIt_NEW 2>&1 |dos2unix |expand -t 4 |sed -e "s/-[-]*+$/--------|/g" |sed -e "s/|[ ]*$//g" |sed -e "s/ [ ]*$//g" \
    |grep -i -e "^+" -e "| Value" -e "${STR}"
fi

```


## ms-xx

```SQL
#!/bin/bash

# export MYSQL_PS1='\u@\h [\d] (\C) [\R:\m:\s]> '

#HOST="127.0.0.1"

 PORT="3310"

 USER="xx"
 PASS="xx!@"

#SCHEMA="sys"

MYSQL="/usr/bin/mysql"
MYSQL="mysql.cmd"
MYSQL=${MYSQL}" -A --comments --disable-reconnect"
MYSQL=${MYSQL}" -h${HOST} -u${USER} -p${PASS} -P${PORT} ${SCHEMA}"
MYSQL=${MYSQL}" --ssl-mode=DISABLED"
MYSQL=${MYSQL}" --default-character-set=utf8mb4"

# mysql> select @@autocommit;
# mysql> set sql_log_bin=off;

####################
# MAIN
####################

# [NOTE] autocommit=0 이면 SELECT FETCH 완료 후에도 락이 남아 있음 - DDL 불가
#${MYSQL} --init-command='SET AUTOCOMMIT = 0;' $*
 ${MYSQL} $*
```


## mp-xx

```SQL
$ cat mp-xx
#!/bin/sh

test "x${SQLDB}" = "x" && SQLDB=""

if [ "x${SQLECHO}" = "x0" ]
then
    SQLECHO=""
else
    SQLECHO="-vvv"
fi

if [ "x${SQLSKIP}" = "x" ]
then
    SQLSKIP="-- "
else
    SQLSKIP=""
fi

 MYSQL_PS1=""

 SQLCMD="ms-xx"
#SQLCMD="msl"
## -- }}} OKT
test "x$3" != "x" && SQLCMD="$3"

test "x$#" = "x0" && exit -1
FN="$1"

 OPT="ANALYZE"
 OPT=""
 test "x$2" = "x0" -o "x$2" = "xa" && OPT=""
 test "x$2" = "x2" -o "x$2" = "xt" && OPT="FORMAT=TREE"
 test "x$2" = "x1" -o "x$2" = "xa" && OPT="ANALYZE"

if [ "x${OPT}" = "xANALYZE" -o "x${OPT}" = "xFORMAT=TREE" ]
then
    SQLECHO="-vvv"
fi

if [ ! -f ${FN} ]
then
    if [ -f ${FN}.sql ]
    then
        FN="${FN}.sql"
    else
        echo "(E) '${FN}' not found."; exit -1
    fi
fi

#SQL=`cat ${FN}`
 SQL=`cat ${FN} |grep -i -v "^[- ]*EXPLAIN" |sed -e "s/;[ ]*$//g" `
#SQL=`cat ${FN} |grep -i -v "^[- ]*EXPLAIN" `

KEY_APP=`echo "${SQL}" |grep "/\* [a-z][a-z][a-z]\.[a-z]" |head -2 |sed -e "s;^.*/\* ;;g" |sed -e "s/ .*$//g"`

#echo "KEY_APP=[$KEY_APP]"; exit
#echo "SQL=[$SQL]"; exit

########################################
# FUNCTION
########################################

function doIt
{
    # [TODO] ADD '-vvv' : 10 rows in set, 2 warnings (0.05 sec)
    # ${SQLCMD} -t -vvv 2>&1 << EOF
    #
    ${SQLCMD} -t ${SQLECHO} 2>&1 << EOF

-- SELECT NOW(), CONNECTION_ID();
-- EXPLAIN FOR CONNECTION {connection_id}

SET PROFILING = 1;
EXPLAIN ${OPT} 
${SQL} 
;

${SQLSKIP} SHOW WARNINGS;
${SQLSKIP} SHOW SESSION STATUS LIKE 'Sort%';
${SQLSKIP} SHOW SESSION STATUS LIKE 'Created_tmp%';
${SQLSKIP} SHOW STATUS LIKE '%handler%';

SHOW PROFILE CPU, CONTEXT SWITCHES, PAGE FAULTS, BLOCK IO, SWAPS FOR QUERY 1; 
-- SHOW PROFILE ALL FOR QUERY 0;

EOF

DT=`date "+%Y/%m/%d %H:%M:%S"`
printf "\n# [$DT] E.N.D.. '${FN}' - '${SQLDB}' "
test "x${KEY_APP}" != "x" && printf "/* ${KEY_APP} */"
echo ""
}

########################################
# MAIN
########################################

GREP="grep --color=auto"

YMD=`date "+%Y%m%d"`

#doIt ; exit 0

#
# [NOTE] 
# 1 | 2  | 3           | 4     | 5          | 6    | 7             | 8   | 9       | 10  | 11   | 12       | 13
#   | id | select_type | table | partitions | type | possible_keys | key | key_len | ref | rows | filtered | Extra
#
#   SKIP $7 --> possible_keys
#   SKIP $4 --> partitions
#   (MOD) "| NULL |" --> "|NULL|"
#
#   $ sed -n -e '/main/,/^}/p' main.c
#   $ sed -n -e '/BEGIN/, /END/p' file
#

doIt 2>&1 \
|dos2unix \
|grep -v "can be insecure" \
|grep -v "^\-\-" \
> .doIt.out

P1=`grep -n "^SHOW PROFILE" .doIt.out |sed -e "s/:.*$//g"`
P2=`grep -n "^Bye" .doIt.out |sed -e "s/:.*$//g"`
test "x${P1}" = "x" && P1=$P2

head -n `expr ${P2} - 3` .doIt.out |tail -n `expr ${P2} - ${P1} - 3` > .doIt.out.PERF
sed "${P1},${P2}d" .doIt.out > .doIt.out.0

cat .doIt.out.0 \
|sed -e "s/\+\-\-/|--/g" \
|sed -e "s/\+$/|/g" \
|sed -e "s/^| NULL |/|NULL |/g" \
|awk 'BEGIN{ FS="|"}{if (NF!=14) print $0; else print "|"$2"|"$3"|"$4"|"$6"|"$11"|"$8"|"$13"|"$10"|"$12"|"$9"|"}' \
|cut -c 1-1000 \
|sed -e "s/ [ ]*$//g" \
|grep -v "^| Note " \
|grep -v "\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-\-" \
> .doIt.out

DT=`date "+%Y/%m/%d %H:%M:%S"`
echo ""
echo "#"
printf "# [$DT] START.. "
test "x${KEY_APP}" != "x" && printf "/* ${KEY_APP} */"
echo ""
echo "# [$DT] EXPLAIN ${OPT} '${FN}'"
echo "#"

if [ "x${OPT}" = "xANALYZE" -o "x${OPT}" = "xFORMAT=TREE" ]
then

# (1) -vvv 에 의해 출력되는 윗쪽 SQL을 제거
#   | sed -n -e '/^| EXPLAIN/,/^E\.N\.D\./p'
# (2) TREE 형태 PLAN에서 들여쓰기를 1칸으로 변경
#   | sed -e "s/  / /g"
#
 COST='[0-9][0-9][0-9]' # LARGE DB
 COST='[0-9][0-9]'      # SMALL DB
#COST='[0-9]'

    if [ "x${OPT}" = "xANALYZE" ]
    then
        # cat .doIt.out.PERF |${GREP} -e ^ -e "[1-9]${COST}"
        cat .doIt.out.PERF |grep "^[+|]" |grep -v "| [ ]*0.0000[012]. | [ ]*0.0000.. | [ ]*0.0000.. |" |${GREP} -e ^ -e "[1-9]${COST}"
    fi

    cat .doIt.out \
|grep -v "Query OK, 0 rows affected" |grep -v "^$" \
|sed -n -e '/^| EXPLAIN/,/^E\.N\.D\./p' \
|sed -e "s/  / /g" \
|sed -e "s/  / /g" \
|sed -e "s/^|[ ]*->/->/g" \
|sed -e "s/ibs_ic_..\.//g" \
|${GREP} -i -e ^ -e " | ALL" -e "Using temporary" -e "Backward .* scan" -e "Using filesort" -e "Materialize" -e "Hash" -e "for each" -e "FirstMatch" -e "Temporary" -e "Recursive" \
         -i -e "skip scan" -e "Start temporary" -e "End temporary" -e "weedout" \
         -e "^.* | ${COST}[0-9][0-9][0-9]* |.*$" \
         -e "rows=[0-9]${COST}" \
         -e "loops=${COST}" \
         -e "actual time=[0-9]${COST}"
else
    cat .doIt.out \
|grep -v "Query OK, 0 rows affected" |grep -v "^$" \
|sed -n -e '/^| id [ ]*| select_type/,/^E\.N\.D\./p' \
|sed -e "s/|NULL |/|NULL|/g" \
|${GREP} -i -e ^ -e " | ALL" -e "Using temporary" -e "Backward .* scan" -e "Using filesort" -e "Materialize" -e "Hash" -e "for each" -e "FirstMatch" -e "Temporary" -e "Recursive" \
         -i -e "skip scan" -e "Start temporary" -e "End temporary" -e "weedout" \
         -e "^.* | ${COST}[0-9][0-9][0-9]* |.*$" \
         -e " |  ${COST}[0-9]* "
fi

CHK=`grep ^ERROR .doIt.out |wc -l |sed -e "s/ //g"`
if [ "x$CHK" != "x0" ]
then
    cat .doIt.out
fi

#|tee -a ${YMD}_`echo "${FN}"|sed -e "s/\..*//g" |tr [a-z] [A-Z]`.plan.out

exit 0


#
# ETC
#

|sed -e "s/|[ ]*$//g" \
|sed -e "s/ [ ]*$//g" \
|awk 'BEGIN{ FS="|"}{if (NF!=13) print $0; else print "|"$2"|"$3"|"$4"|"$6"|"$8"|"$9"|"$10"|"$11"|"$12"|"$13}' \

|-----|--------------------|----------|--------|------------|---------|-------|----------|----------|----------------------------------+
| id  | select_type        | table    | type   | key        | key_len | ref   | rows     | filtered | Extra
|-----|--------------------|----------|--------|------------|---------|-------|----------|----------|----------------------------------+
|   1 | PRIMARY            | A        | index  | PRIMARY    | 82      | NULL  | 39736988 |    10.00 | Using where; Backward index scan
| 117 | DEPENDENT SUBQUERY | NULL     | NULL   | NULL       | NULL    | NULL  |     NULL |     NULL | no matching row in const table

```


## desc.my-xx

```SQL
$ cat desc.my-xx
#!/bin/sh

test "x"${SQLDB} = "x" && SQLDB=""

MYSQL_PS1=""
 SQLCMD="msl"
#SQLCMD="ms-xx"
test "x$2" != "x" && SQLCMD="$2"

TBL="$1"

########################################
# FUNCTION
########################################

function doIt
{
    ${SQLCMD} -s << EOF
SHOW CREATE TABLE ${TBL} ;
EOF
}

function doIX
{
    ${SQLCMD} -s << EOF
SHOW INDEX FROM ${TBL} ;
EOF
}

function doCnt_PRE
{
    ${SQLCMD} -s << EOF
SELECT /*+ MAX_EXECUTION_TIME(5000) */ CONCAT( 'CUT=', FORMAT( COUNT(*), 0 ) ) FROM ${TBL} ;
EOF
}

function doCnt
{
    ${SQLCMD} -s << EOF
SELECT /*+ MAX_EXECUTION_TIME(5000) */ 
       CONCAT( 'CUT=', FORMAT( CNT, 0 ) ) 
  FROM 
(
SELECT 
       -- CASE WHEN MAX_DATA_LENGTH < (1024*1024*1024*10) THEN (SELECT COUNT(*) FROM ${TBL}) 
       CASE WHEN DATA_LENGTH < (1024*1024*1024*1 ) THEN (SELECT COUNT(*) FROM ${TBL}) 
            ELSE GREATEST( TABLE_ROWS, ROUND(DATA_LENGTH/AVG_ROW_LENGTH,0) ) -- [NOTE] ANALYZE를 강제수행해도 동기화가 잘안된다. 
        END AS CNT
  FROM information_schema.TABLES
 WHERE TRUE
   -- AND TABLE_NAME = '${TBL}'
   AND TABLE_NAME = SUBSTR('${TBL}', INSTR('${TBL}','.')+1)
   AND TABLE_SCHEMA NOT LIKE '%BACK%' -- 
 LIMIT 1
) X
;

-- SELECT /*+ MAX_EXECUTION_TIME(5000) */ CONCAT( 'CUT=', FORMAT( COUNT(*), 0 ) ) FROM ${TBL} ;
EOF
}

########################################
# MAIN
########################################

TABLEN=24
TABLEN=32
TABLEN=40

# doIt ; exit 0
echo ""
echo "#"
echo "# ${TBL}"
echo "#"
echo ""

doIt 2>/dev/null \
|dos2unix \
|sed -e "s/ CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_ci//g" \
|sed -e "s/ COLLATE utf8mb4_0900_as_ci//g" \
|sed -e "s/ DEFAULT NULL//g" \
|sed -e "s/ [ ]*COMMENT/\tCOMMENT/g" \
|sed -e "s/ [ ]*varchar/\tvarchar/g" \
|sed -e "s/ [ ]*varbinary/\tvarbinary/g" \
|sed -e "s/ [ ]*tinytext/\ttinytext/g" \
|sed -e "s/ [ ]*tinyint/\ttinyint/g" \
|sed -e "s/ [ ]*timestamp/\ttimestamp/g" \
|sed -e "s/ [ ]*time/\ttime/g" \
|sed -e "s/ [ ]*text/\ttext/g" \
|sed -e "s/ [ ]*smallint/\tsmallint/g" \
|sed -e "s/ [ ]*set/\tset/g" \
|sed -e "s/ [ ]*mediumtext/\tmediumtext/g" \
|sed -e "s/ [ ]*mediumblob/\tmediumblob/g" \
|sed -e "s/ [ ]*longtext/\tlongtext/g" \
|sed -e "s/ [ ]*longblob/\tlongblob/g" \
|sed -e "s/ [ ]*json/\tjson/g" \
|sed -e "s/ [ ]*int/\tint/g" \
|sed -e "s/ [ ]*float/\tfloat/g" \
|sed -e "s/ [ ]*enum/\tenum/g" \
|sed -e "s/ [ ]*double/\tdouble/g" \
|sed -e "s/ [ ]*decimal/\tdecimal/g" \
|sed -e "s/ [ ]*datetime/\tdatetime/g" \
|sed -e "s/ [ ]*date/\tdate/g" \
|sed -e "s/ [ ]*char/\tchar/g" \
|sed -e "s/ [ ]*blob/\tblob/g" \
|sed -e "s/ [ ]*binary/\tbinary/g" \
|sed -e "s/ [ ]*bigint/\tbigint/g" \
|sed -e "s/ [ ]*xxx/\txxx/g" \
|sed -e "s/^.*CREATE TABLE/CREATE TABLE/g" \
|sed -e "s/ USING BTREE//g" \
|sed -e "s/\\\n/\n/g" \
|expand -t ${TABLEN} \
|sed -e "s/\`//g" \
|sed -e "s/  COMMENT=/COMMENT=/g" \
|tee .desc.doIt.out


printf ";\n\n"

doIX 2>/dev/null |dos2unix > .desc.doIX.out

echo "/* ## CARDINALITY - SHOW INDEX FROM ${TBL} ## " 
echo ""
LIST=`cat .desc.doIt.out |sed -e "s/^ [ ]*PRIMARY KEY /  KEY PRIMARY /g" |sed -e "s/^ [ ]*UNIQUE KEY /  KEY /g" |grep "^ [ ]*KEY " |awk '{print $2}'`
for X in $LIST
do
   #CARD=`cat .desc.doIX.out |grep -P "\t${X}\t1" |awk '{print $7}'`
    CARD=`cat .desc.doIX.out |grep -P "\t${X}\t" |tail -1 |awk '{print $7}'`
    printf "   %s.%-20s\t= [%12s]\n" ${TBL} ${X} ${CARD} |expand -t ${TABLEN} |sed -e "s/  = \[/= \[/g"
done
echo "*/"
echo ""

DT=`date "+%Y/%m/%d %H:%M:%S"`

#doCnt ; exit 0
CNT=`doCnt 2>&1 |dos2unix |grep "CUT=" |sed -e "s/CUT=//g"`
COMMENT=`cat .desc.doIt.out |grep "COMMENT=" |tail -1 |sed -e "s/^.*COMMENT=//g"`
    printf "   %s (%-20s)\t= [%12s] ROWS [$DT]\n" ${TBL} "${COMMENT}" ${CNT} |expand -t ${TABLEN} |sed -e "s/  = \[/= \[/g"

exit 0
```

