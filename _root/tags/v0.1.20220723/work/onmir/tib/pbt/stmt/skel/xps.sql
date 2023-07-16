select * from table( dbms_xplan.display_cursor( sql_id => '&sql_id' , format => 'ALLSTATS LAST ALL' ) );
