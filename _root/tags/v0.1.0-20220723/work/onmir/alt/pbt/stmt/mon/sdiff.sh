sdiff -w 240 1.sql 2.sql |cat8 |grep -n ^ |sed -e "s/^[0-9][0-9][0-9]:/ &/g" |sed -e "s/^[0-9][0-9]:/  &/g" |grep -e " | "

