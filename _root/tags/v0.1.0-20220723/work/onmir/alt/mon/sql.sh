getLog()
{
grep "[0-9]\] EXECUTE_TIME= \[[1-9]" logs/ALTIMON_DB01.log
}

#getLog | tr -d [\]\[] #|cut -d' ' -f4,20- |sort -n
getLog | tr -d [\]\[] | while :
read a b c d e f g h i j k l m n o
do
        eTime=$d     # elapsed time
        sNum=$m      # session id
        query=$o     # query
        #----------------------------
        # echo with delimeter
        #----------------------------
        echo "$eTime#$sNum#$query"
done > 1.txt

awk -F# '{
                # elapsed time
        if($1<=30) next;

                # same session id
        if(sess[$2] == "") sess[$2] = $3;
                # max elapsed session
        if (time[$2] < $1) time[$2] = $1;
    } END {
        for (a in sess) {
            printf("%-10s%-s\n", time[a], sess[a]);
        }
}' < 1.txt > 2.txt

cat 2.txt |sort -n
