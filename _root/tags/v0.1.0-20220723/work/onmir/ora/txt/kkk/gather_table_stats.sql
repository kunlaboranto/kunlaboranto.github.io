exec dbms_stats.gather_table_stats(user, 't_dynamic', -
       cascade=>true,-
       no_invalidate=>false);


/*
SQL > begin
                 dbms_stats.gather_table_stats
                 ( user, 'T',
                 method_opt=>'for all indexed columns size 254' );
        end;
        /
*/
