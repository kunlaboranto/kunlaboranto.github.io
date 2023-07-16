create or replace function print_table_pl
( p_query in varchar2,
  p_date_fmt in varchar2 default 'dd-mon-yyyy hh24:mi:ss' )
return sys.odcivarchar2list 
authid current_user
pipelined
   is
l varchar2(4000);
s integer default 1;
begin
  dbms_output.enable(buffer_size => null);
  
  PRINT_TABLE_PL_SUB(
     p_query => p_query,
     p_date_fmt => p_date_fmt
  );

  loop
     dbms_output.get_line(line => l, status => s);
     exit when s != 0;
     begin
        pipe row(l);
     exception when no_data_needed then exit;
     end;
  end loop;
    
  return;

end PRINT_TABLE_PL;
/
