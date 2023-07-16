create or replace function SYS.UX2DATE(A_TIMESTAMP in VARCHAR(13))
return DATE
as
V_DATE DATE;
V_H2S INTEGER;
V_LEN INTEGER;
begin

    select LENGTH(A_TIMESTAMP) into V_LEN from DUAL;

    if V_LEN = 13 then
        select (1*24*60*60*1000) into V_H2S from DUAL;
    elseif V_LEN = 10 then
        select (1*24*60*60) into V_H2S from DUAL;
    else
        --return to_date('99990909','YYYYMMDD');
        return NULL;
    end if;

    select
        TO_DATE('1970010109','YYYYMMDDHH24') + A_TIMESTAMP / V_H2S
        into V_DATE
    from DUAL;

    return V_DATE;

exception
    when others then
        --return to_date('99990909','YYYYMMDD');
        return NULL;
end;
/

GRANT EXECUTE ON SYS.UX2DATE TO PUBLIC;
