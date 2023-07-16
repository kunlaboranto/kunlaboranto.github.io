insert into T1 values ( 1, 'asdf', '한글(1,1)', sysdate );
insert into T1 values ( 2, 'asdf', '한글(1,1)', sysdate );
insert into T1 values ( 3, 'asdf', '한글(1,1)', sysdate );
insert into T1 values ( 9, 'asdf', '한글(1","1)', sysdate );
insert into T1 values ( 10, '### LINE1
LINE2', '한글(1,1)', sysdate );

commit;

SELECT * FROM T1 ;
