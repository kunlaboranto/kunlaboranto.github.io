INSERT INTO OKT
SELECT * FROM REMOTE_TABLE(DEV01_LINK, '
SELECT * FROM OKT WHERE NO = ''20010046932'' AND YYMM = ''202010'' LIMIT 2
'
);

