set serveroutput on;

create or replace procedure print_table( p_query in varchar2 )
--create procedure print_table( p_query in varchar2 )
AUTHID CURRENT_USER
is
    l_theCursor     integer default dbms_sql.open_cursor;
    l_columnValue   varchar2(4000);
    l_status        integer;
    l_descTbl       dbms_sql.desc_tab;
    l_colCnt        number;
begin
    dbms_sql.parse(  l_theCursor,  p_query, dbms_sql.native );
    dbms_sql.describe_columns( l_theCursor, l_colCnt, l_descTbl );

    for i in 1 .. l_colCnt loop
        dbms_sql.define_column(l_theCursor, i, l_columnValue, 4000);
    end loop;

    l_status := dbms_sql.execute(l_theCursor);

    while ( dbms_sql.fetch_rows(l_theCursor) > 0 ) loop
        for i in 1 .. l_colCnt loop
            dbms_sql.column_value( l_theCursor, i, l_columnValue );
            dbms_output.put_line( rpad( l_descTbl(i).col_name, 30 ) || ': ' || l_columnValue );
        end loop;
        dbms_output.put_line( '-----------------' );
    end loop;
exception
    when others then
     raise;
end;
/

--create public synonym PRINT_TABLE for US_GDMON.PRINT_TABLE;
--grant execute on PRINT_TABLE to public;

