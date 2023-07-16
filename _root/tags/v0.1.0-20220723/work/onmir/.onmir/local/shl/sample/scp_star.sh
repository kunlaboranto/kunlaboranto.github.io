#!/bin/bash

function usage () {
    printf "usage: target password src [src2 ..] \n"
    exit 1
}

if [ $# -lt 3 ]
then
    usage
fi

export TARGET_PATH=$1
export PASSWD=$2
export SRC_PATH=""

declare rc=0
function f_scp()
{
/usr/bin/expect << 'EOF'
	set timeout -1
	set TARGET_PATH $::env(TARGET_PATH)
	set PASSWD $::env(PASSWD)
	set SRC_PATH $::env(SRC_PATH)

	set match ""
	regexp "@" $TARGET_PATH match
	if { $match != "@" } {
		puts "(E) 'target' must have '@'"
		exit 1
	}

	spawn scp "$SRC_PATH" "$TARGET_PATH"
	expect {
		-re "yes/no" { send "yes\r"; exp_continue }
		-re "password:" { send "$PASSWD\r"; exp_continue }
	}
	catch wait result
	exit [lindex $result 3]
EOF
	rc=$?
	if [ "x"$rc != "x0" ]
	then
		printf "(E) 'scp $SRC_PATH $TARGET_PATH' error ($rc)\n"
		return "$rc"
	fi
}

########################################
# MAIN
########################################

LOG=".sh.log"

until [ -z "$3" ]
do
	SRC_PATH=$3
	printf "\n"
	printf ">> Start.. 'scp $SRC_PATH $TARGET_PATH'\n"

	# 아래와 같이 바로 grep하면 rc 값을 체크할 수 없다.
	#f_scp |grep -v -E "The|Illegal|Please|spawn|password:"
	f_scp > ${LOG} 2>&1 ; rc=$?
	cat ${LOG} |grep -v -E "The|Illegal|Please|spawn|password:"
	if [ "x"$rc != "x0" ]
	then
		break;
	fi
	shift
done

rm -f ${LOG}
exit $rc

