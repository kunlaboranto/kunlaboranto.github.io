drop table T1;
create table T1
(
    C1 NUMBER(10),
    C2 VARCHAR2(20),
    C3 VARCHAR2(20 CHAR),
    C4 DATE default sysdate
);

COMMIT;
