#!/bin/bash
# -x
# tcpdump로 패킷을 모니터링 하는 스크립트이다.
trap "exit 0" 0 1 2 24
ORIFS=$IFS
tempfile=tcpdump.txt
if [ -f "tcpdump.txt" ]
then
yes | rm -i tcpdump.txt
fi
# 스크립트 실행 시 입력받은 인자값을 변수에 할당한다.
INTERFACE=$1
INTERVAL=$2
ROTATE=$3
# let을 이용하여 산술식 계산 후 변수에 할당한다.
let TOTALTIME=$INTERVAL*$ROTATE
CNTVAL=1
#expr로도 가능하다.
SLEEPVAL=`expr $INTERVAL - 2`

while (( CNTVAL <= TOTALTIME ))
do
    sleep $SLEEPVAL
    if [[ $INTERFACE == "ALL" ]]
    then
        timeout 2 tcpdump -nn 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and tcp' >> tcpdump.txt
    elif [[ $INTERFACE != "ALL" ]]
    then
        DSTIP=$(ifconfig enp0s3 | awk '{ if($1=="inet") { print $2} }')
		# tcpdump 명령을 2초동안 실행 시키고 그 결과를 파일에 저장한다.
		# tcp[tcpflags] & (tcp-fin|tcp-push는 fin과 push 요청만 캡처 하겠다는 의미이다.
		# nn은 -h 처럼 분석이 편하도록 결과값을 가공 i는 인터페이스 지정
        echo "timeout 2 tcpdump -nni $INTERFACE 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and dst $DSTIP and tcp'"
        timeout 2 tcpdump -nni $INTERFACE 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and dst '"$DSTIP"' and tcp' >> tcpdump.txt
    fi
(( CNTVAL+=INTERVAL ))
done
IFS=$'\n'
IPPORTCNT=
FINDIPVAR=
SYNFINREQ=
PUSHREQ=

awk '{ if ($5 != "") { print $5,$7 }} ' tcpdump.txt | awk 'BEGIN { FS=":" } { print $1,$2 }' > exptipdump
awk '{ if ( $5 != "" ){ print $5 } }' tcpdump.txt | sort | uniq | awk ' BEGIN { FS=":" } { print $1 } ' > uniqipdump
if [ -f "reporttcpdump.txt" ]
then
yes | rm -i reporttcpdump.txt
fi
echo "-------------------------------------TCP PACKET REPORT-------------------------------------" > reporttcpdump.txt
echo "   IP ADDRESS           PORT NUM        REQ CNT         SYN/FIN REQ CNT      PUSH REQ CNT" >> reporttcpdump.txt

for arg in $(cat uniqipdump)
do
# awk 명령은 BEGIN을 통해 변수값을 최초 선언하고 END를 통해 명령 종료 시점에 처리할 내용을 지정 할 수있다.
FINDIPVAR=$(echo $arg | awk ' BEGIN { FS=" " } { print $1 }')
IPPORTCNT=$(echo $FINDIPVAR | awk ' BEGIN { FS="."} END { OFS="."; print $1,$2,$3,$4,$5; } ')
IPPORTCNT=$IPPORTCNT"."$(awk 'BEGIN { ipcnt=0; }  { if ( $1 == "'$FINDIPVAR'" ) {ipcnt++; } }  END { print ipcnt; } ' exptipdump)
IPPORTCNT=$IPPORTCNT"."$(sed -n '/'"$FINDIPVAR"'  \[F\.\],/p' exptipdump | wc -l)
IPPORTCNT=$IPPORTCNT"."$(sed -n '/'"$FINDIPVAR"'  \[P\.\],/p' exptipdump | wc -l)
echo $IPPORTCNT | awk ' BEGIN { FS="."} END { OFS="."; print "IP: " $1,$2,$3,$4 "        PORT: " $5 "      REQ: " $6 "          SYN/FIN REQ : " $7 "      PUSH REQ : "$8; } '  >> reporttcpdump.txt
done

IFS=$ORIFS
exit 0
