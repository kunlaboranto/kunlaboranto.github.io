select
 thread# "Thread#",
 substr(to_char(first_time,'yyyy/mm/dd'),1,10) "Day",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'00',1,0))) "00",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'01',1,0))) "01",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'02',1,0))) "02",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'03',1,0))) "03",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'04',1,0))) "04",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'05',1,0))) "05",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'06',1,0))) "06",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'07',1,0))) "07",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'08',1,0))) "08",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'09',1,0))) "09",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'10',1,0))) "10",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'11',1,0))) "11",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'12',1,0))) "12",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'13',1,0))) "13",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'14',1,0))) "14",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'15',1,0))) "15",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'16',1,0))) "16",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'17',1,0))) "17",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'18',1,0))) "18",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'19',1,0))) "19",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'20',1,0))) "20",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'21',1,0))) "21",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'22',1,0))) "22",
 decode(sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0)),0,0,sum(decode(substr(to_char(first_time,'HH24'),1,2),'23',1,0))) "23",
 decode(sum(1),0,0,sum(1)) "Per Day"
from v$log_history
where first_time >= trunc(sysdate-14)
group by thread#,substr(to_char(first_time,'yyyy/mm/dd'),1,10)
order by substr(to_char(first_time,'yyyy/mm/dd'),1,10) desc, thread#
;
