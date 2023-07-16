#!/bin/sh

function doIt
{
is -silent << EOF
-- v$segment.extent_full_count 는 없어짐
--
    set linesize 120;
    set colsize 30;
    
    select  
        c.name tbs_name,
        b.user_name||'.'||a.table_name table_name,
        round(c.extent_page_count * c.page_size * d.extent_total_count/1024/1024, 3) alloc,
        --round(c.extent_page_count * c.page_size * d.extent_full_count/1024/1024, 3) used,
        --decode(d.extent_full_count, 0, '-', round(d.extent_full_count * 100 / d.extent_total_count, 3) ) '%USED' 
        -1 used
    from system_.sys_tables_ a, system_.sys_users_ b, v\$tablespaces c, v\$segment d
    where a.user_id = b.user_id 
        and a.tbs_id = c.id 
        and d.table_oid = a.table_oid 
        and d.segment_type='TABLE' 
        and a.tbs_id != 0 
        and a.user_id != 1
        and b.user_name <> 'SYSTEM_'
        --and b.user_name = 'MIG'
        and ( c.name like upper('%$1%') OR a.table_name like UPPER('%$1%') )
    --order by alloc desc, table_name
    order by tbs_name, table_name
    --limit 20
    ;
EOF
}


if [ $# = 1 ]
then
    TBS=$1
else
    TBS="TS_CDSKDT01"
fi

#doIt $TBS |grep -v "0.25"
doIt $TBS 
