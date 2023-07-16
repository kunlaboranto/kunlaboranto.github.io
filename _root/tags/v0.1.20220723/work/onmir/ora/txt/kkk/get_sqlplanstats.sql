select * from sys.v_$sql_plan_statistics_all
where HASH_VALUE = '593239587'
and CHILD_NUMBER = 0; --메모리에 남아있는 통계정보 조회(과거거는 ???)


--위 테이블을 이용해서 만들어진 function
select system.get_sqlplanstats('1840906846', 0)
from dual;
데이타 있는 조건
select system.get_sqlplanstats('593239587', 0)
from dual;

