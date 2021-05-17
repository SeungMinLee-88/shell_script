#!/bin/bash
export NCURSES_NO_UTF8_ACS=1


TEST="test11\n"
TEST=$TEST"test22\n"
printf $TEST
exit 0
#CentOS 6, 7
#
#** 추가 내용 위치 주의
#
###x-window 및 SSH 접속
#
#[root@localhost ~]# /etc/pam.d/password-auth
#
#...
#https://kifarunix.com/enforce-password-complexity-policy-on-centos-7-rhel-derivatives/
#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=
#password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type= minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1 enforce_for_root
#password    requisite     pam_cracklib.so try_first_pass retry=3 type=minlen=8
#https://nowknowing.tistory.com/113
#auth        required    pam_env.so
#auth        required    pam_tally2.so deny=3 unlock_time=60
#auth        sufficient   pam_unix.so nullok try_first_pass
#auth        requisite    pam_succeed_if.so uid >= 500 quiet
#auth        required    pam_deny.so
#
#account    required    pam_unix.so
#account    required    pam_tally2.so
#account    sufficient   pam_localuser.so
#account    sufficient   pam_succeed_if.so uid < 500 quiet
#account    required    pam_permit.so
#while
#while은 루프 최상단에서 특정 조건을 확인하면서 그 조건이 참일 동안 루프를 계속 돌도록 해 줍니다(종료 상태 0
#을 리턴합니다).
#while [condition] ; do
#while [condition]
#ex find and change
#ex extest +/password    requisite/ +s/"password    requisite     pam_pwquality.so try_first_pass local_users_only authtok_type= minlen=8 retry=1"/"password    requisite     pam_pwquality.so try_first_pass local_users_only authtok_type= minlen=8 retry=3"/ -s +'p|w|q!'
# find search text and change search result line number text
# Use the above command or the following
# Change by specifying line number
#ex extest +15s/"password    requisite     pam_pwquality.so try_first_pass local_users_only authtok_type= minlen=8 retry=1"/"password    requisite     pam_pwquality.so try_first_pass local_users_only authtok_type= minlen=8 retry=3"/ -s +'p|w|q!'
#Ex command addresses
#
#n     line n      /pat   next with pat
#
#.     current     ?pat   previous with pat
#
#$     last        x-n    n before x
#
#+     next        x,y    x through y
#
#-     previous    'x     marked with x
#
#+n    n forward   ''     previous context
#
#%     1,$
# specifying line number awk command
#vmstat | awk '{if (NR==3) { print NR $0 }}'
#[root@master ~]# iostat 1 1 | awk '{if (NR>5) { print }}'
#ex delete and change example
#ex extest +'15d' +'15p'  +'i|123'  -s +'1,$|q!'
#ex extest +/password    requisite/ +'d' +'15p'  +'i|password    requisite     pam_pwquality.so try_first_pass local_users_only authtok_type= minlen=8 retry=3'  -s +'1,$|w|q!'
#ex login.defs_test +/^"PASS_MIN_LEN\t8"/ -s +'p|q!'
#ex login.defs_test +/^"PASS_MIN_LEN"/ +'d' +$'i|PASS_MIN_LEN\t8' -s +'20,30|q!'

#sed change file content number character 1,5 or 3 mean apply line -n mean silent(none print not match text) -i mean change write original file And follows that  the text wrapped to single quotes mean make backup file /p is mean cheange content print and "/g" is mean apply change to file command first line to last line
# sed -ni'.bak' '1,5s/bin/nib/gp' sedchgtest
#sed -i '25s/# lcredit = 1/lcredit = 1/g' pwquality.conf_test
#cat -n pwquality.conf_test|sed -n '/lcredit = 1/p' | awk '{ print $1 }'
# insert after "n"i line
#sed -i '16i test' extest add new specified line
# insert find text after
#sed '/He/a --> Inserted!' geeks.txt
#https://www.baeldung.com/linux/insert-line-specific-line-number
# awk chang file content
#echo "asd:def:ghj" | awk 'BEGIN { FS=":";OFS="/";regex=$2 } { $2="chg";print $1,$2,$3}'
# FS mean input seperatro OFS mean output seperator
#echo "asd:def:ghj" | awk 'BEGIN { FS=":";OFS="/";regex="testing.." } { printf(regex "\n") }'
#testing..
#
#awk 'BEGIN { FS=":";OFS="/" } { if ((($1=="Bucks") && (NR==7)) || (($1=="Bucks") && (NR==19))) {  $1="chg";} } { print NR,$0}' teams.txt
#
#awk 'BEGIN { FS=":";OFS="/" } { if ((($1=="Bucks") && (NR==7)) || (($1=="Bucks") && (NR==19))) {  $1="chg";} } { print }' teams.txt > teams.txt_bak


#read
#echo "제일 좋아하는 야채가 $REPLY 군요."
# REPLY 는 가장 최근의 "read"가 변수 없이 주어졌을 때 그 값을 담고 있습니다.
COUNT=0
TESTCOUNT=22

while [ $COUNT != 50 ]
do
COUNT=$(expr $COUNT + 10)
args=$COUNT
#echo "XXX"
#echo $TESTCOUNT
#echo "XXX"
#echo "args : "$args
echo $COUNT
sleep 1
done | dialog --title "My Gauge" --gauge "Hi, this is a gauge widget" 20 70 0
exit 0

#exec 3>&0
#exec 0>&1
#exec 0>&1
#exec 1>&3
#exec 0<$(cat readtest.txt)
#exec 0<&1
#cat readtest.txt >&0
read percent <<< $(echo "123") | sleep 10
#exec 0>&3-
#read percent2
echo "percent : "$percent
#echo "percent2 : "$percent2
exit 0

while [ $COUNT != 50 ]
do
COUNT=$(expr $COUNT + 10)
args=$COUNT
#echo "XXX"
#echo $TESTCOUNT
#echo "XXX"
read percent 0<$(echo $COUNT)
#echo "args : "$args
#echo "COUNT : "$COUNT

sleep 1
done | dialog --title "My Gauge" --gauge "Hi, this is a gauge widget" 20 70 0
exit 0


while test $COUNT != 100
do
echo $COUNT
echo "XXX"
echo "The new\\nmessage ($COUNT percent)"
echo "XXX"
COUNT=$(expr $COUNT + 30)
dialog --title "My Gauge" --gauge "Hi, this is a gauge widget" 20 70 $COUNT
continue
sleep 1
done
exit 0

read percent
dialog --title "My Gauge" --gauge "Hi, this is a gauge widget" 20 70 $percent

exit 0
COUNT=40
(
while test $COUNT != 130
do
echo $COUNT
echo "XXX"
echo "The new\\nmessage ($COUNT percent)"
echo "XXX"
COUNT=$(expr $COUNT + 30)
sleep 1
done
)
