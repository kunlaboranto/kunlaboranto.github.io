-- ex)
-- v$session.LOGIN_TIME
-- iSQL> select ux2date('1239079710') from dual;
-- 2009/04/07 13:48:30  

create or replace function ux2date(a_timestamp in varchar(13))
--create function ux2date(a_timestamp in varchar(13))
return date
as
v_date date;
v_h2s integer;
v_len integer;
begin

    select length(a_timestamp) into v_len from dual;

    if v_len = 13 then
        select (1*24*60*60*1000) into v_h2s from dual;
    elseif v_len = 10 then
        select (1*24*60*60) into v_h2s from dual;
    else
        return to_date('99990909','YYYYMMDD');
    end if;

    select
        to_date('1970010109','YYYYMMDDHH24') + a_timestamp / v_h2s
        into v_date
    from dual;

    return v_date;

exception
    when others then
        return to_date('99990909','YYYYMMDD');
end;
/
