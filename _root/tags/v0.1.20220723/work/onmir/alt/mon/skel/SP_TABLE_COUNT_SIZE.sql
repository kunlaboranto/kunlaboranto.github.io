CREATE OR REPLACE PROCEDURE SYS.SP_TABLE_COUNT_SIZE()
as
    V_USER_NAME VARCHAR(40);
    V_TABLE_NAME VARCHAR(40);
    V_STATUS     VARCHAR(3);


    cursor C1 is
    SELECT B.USER_NAME,A.TABLE_NAME,SUBSTR(C.NAME,5,3) STATUS
       FROM SYSTEM_.SYS_TABLES_ A
    INNER JOIN SYSTEM_.SYS_USERS_ B 
            ON A.USER_ID=B.USER_ID
            AND B.USER_NAME IN ('US_xx')
    inner join  V$TABLESPACES C
    on A.TBS_ID = C.ID
    where A.TABLE_TYPE='T' --테이블형식인것만.
      and A.TABLE_NAME NOT LIKE '%KSIGN'
      and A.TABLE_NAME NOT LIKE '%OKT'
    --  AND a.table_name = 'KAA111MT'
    --  limit 10
    ;

    V_SQL VARCHAR(1024);

begin

    open C1;
    loop
        fetch C1 into V_USER_NAME, V_TABLE_NAME , V_STATUS;
        exit when C1%NOTFOUND;
        
            -- # COUNT
            V_SQL := 'INSERT INTO SYS.SUM_TABLE_IL VALUES ('''||V_USER_NAME||''','''||V_TABLE_NAME||''',(SELECT COUNT(*) FROM '||V_USER_NAME||'.'||V_TABLE_NAME||')); ' ;
            EXECUTE IMMEDIATE V_SQL; --into V_CNT_TB;
            

        if V_STATUS = 'MEM' then  --메모리테이블

            V_SQL := ' insert into SYS.TABLE_SIZE_ROW
            SELECT TO_CHAR(SYSDATE,'||'''YYYYMMDD'''||'),
                  c.user_name,
                  a.table_name,
                  d.name tbs_name,
                  a.table_oid,
                  e.ROW_CNT ,
                  round((b.mem_page_cnt*8)/1024) AS ALLOC_M
             FROM system_.sys_tables_ a,
                  v$memtbl_info b,
                  system_.sys_users_ c,
                  v$tablespaces d,
                  SUM_TABLE_IL e
            WHERE a.table_oid = b.table_oid
                  and a.user_id = c.user_id
                  and a.tbs_id=d.id
                  and a.table_name = e.table_name
                  and c.user_name = '''||V_USER_NAME||'''
                  and e.table_name = '''||V_TABLE_NAME||''';';  


        ELSE 

            -- # COUNT 및 테이블
            V_SQL := ' insert into SYS.TABLE_SIZE_ROW
            SELECT TO_CHAR(SYSDATE,'||'''YYYYMMDD'''||'),
                  c.user_name,
                  a.table_name,
                  d.name tbs_name,
                  a.table_oid,
                  e.ROW_CNT ,
                  round((b.disk_page_cnt*8)/1024) AS ALLOC_M
             FROM system_.sys_tables_ a,
                  v$disktbl_info b,
                  system_.sys_users_ c,
                  v$tablespaces d,
                  SUM_TABLE_IL e
            WHERE a.table_oid = b.table_oid
                  and a.user_id = c.user_id
                  and a.tbs_id=d.id
                  and a.table_name = e.table_name
                  and c.user_name = '''||V_USER_NAME||'''
                  and e.table_name = '''||V_TABLE_NAME||''';';  

        end if;

           EXECUTE IMMEDIATE V_SQL;

        

    end loop;
    
    
    close C1;

    COMMIT;
    
end;
/
