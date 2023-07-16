col INDEX_NAME format a30;
col "TYPE" format a30;
col COL_LIST format a60;

set linesize 180
with wx as (
    select i.index_name
         , tc.column_id
         , ic.column_position
         , tc.column_name
         , ic.DESCEND
         --, decode( ic.column_position, null, '', decode( i.uniqueness, 'UNIQUE', 'U', '') ) as is_unique
         , i.uniqueness
         , i.index_type     -- NORMAL, LOB, FUNCTION-BASED NORMAL, FUNCTION-BASED DOMAIN
         , i.NUM_ROWS
         , i.DISTINCT_KEYS
      from 
           ( select 'xx' owner, 'xx' table_name from dual ) p 
           inner join dba_tab_columns tc
                   on tc.owner = p.owner and tc.table_name = p.table_name
           left outer join dba_ind_columns ic
                   on ic.table_owner = tc.owner
                  and ic.table_name = tc.table_name
                  and ic.column_name = tc.column_name
               partition by ( ic.index_name )
           left outer join dba_indexes i
                   on i.table_owner = tc.owner
                  and i.table_name = tc.table_name
                  and i.index_name = ic.index_name
     order by ic.index_name, tc.column_id
)
select 
       --wx.index_name || nvl2( max(wx.uniqueness), ' (U)', '' ) INDEX_name
       wx.index_name 
     , CASE WHEN max(wx.NUM_ROWS) > 0 THEN '(' || LPAD( max(wx.DISTINCT_KEYS), LENGTH( max(wx.NUM_ROWS) ) ) || '/' || max(wx.NUM_ROWS) || ') ' ELSE NULL END
       || max( wx.index_type ) || decode( max( wx.uniqueness ), 'UNIQUE', ',UK', '') 
       AS "TYPE"
     , listagg( nvl2( wx.column_position, wx.column_name || decode( wx.DESCEND, 'ASC', '', ' desc' ), '' ), ', ' )
                within group ( order by wx.column_id )
                as col_list
  from wx
 group by wx.index_name
;

