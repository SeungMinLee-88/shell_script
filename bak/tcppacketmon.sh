#!/bin/bash
# -x
trap "echo \"find interrupt\" ; exit 0" 0 1 2 24
ORIFS=$IFS

#exit 0

tempfile=tcpdump.txt
if [ -f "tcpdump.txt" ] # $filename 에 빈 칸이 들어 있을 수도 있기 때문에 쿼우팅해줍니다.
then
yes | rm -i tcpdump.txt
fi
echo "INTERFACE val : "$1
echo "interval val : "$2
echo "rotate val : "$3
INTERFACE=$1
INTERVAL=$2
ROTATE=$3



echo "INTERFACE val : "$INTERFACE
echo "interval val : "$INTERVAL
echo "rotate val : "$ROTATE

#exit 0

let TOTALTIME=$INTERVAL*$ROTATE
echo "TOTALTIME : "$TOTALTIME
CNTVAL=1
#let SLEEPVAL=$INTERVAL-1
SLEEPVAL=`expr $INTERVAL - 2`
echo "SLEEPVAL : "$SLEEPVAL
#exit 0
while (( CNTVAL <= TOTALTIME ))
do
    sleep $SLEEPVAL
    if [[ $INTERFACE == "ALL" ]]
    then
        timeout 2 tcpdump -nn 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and tcp' >> tcpdump.txt
    elif [[ $INTERFACE != "ALL" ]]
    then
        DSTIP=$(ifconfig enp0s3 | awk '{ if($1=="inet") { print $2} }')
        #echo "DST IP : "$DSTIP
        echo "timeout 2 tcpdump -nni $INTERFACE 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and dst $DSTIP and tcp'"
        timeout 2 tcpdump -nni $INTERFACE 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and dst '"$DSTIP"' and tcp' >> tcpdump.txt
    fi

(( CNTVAL+=INTERVAL ))
echo "CNTVAL : "$CNTVAL
done
echo "done"
#exit 0
IFS=$'\n'
IPPORTCNT=
FINDIPVAR=
SYNFINREQ=
PUSHREQ=

awk '{ if ($5 != "") { print $5,$7 }} ' tcpdump.txt | awk 'BEGIN { FS=":" } { print $1,$2 }' > exptipdump
awk '{ if ( $5 != "" ){ print $5 } }' tcpdump.txt | sort | uniq | awk ' BEGIN { FS=":" } { print $1 } ' > uniqipdump
if [ -f "reporttcpdump.txt" ] # $filename 에 빈 칸이 들어 있을 수도 있기 때문에 쿼우팅해줍니다.
then
yes | rm -i reporttcpdump.txt
fi
echo "-------------------------------------TCP PACKET REPORT-------------------------------------" > reporttcpdump.txt
echo "   IP ADDRESS           PORT NUM        REQ CNT         SYN/FIN REQ CNT      PUSH REQ CNT" >> reporttcpdump.txt

for arg in $(cat uniqipdump)
do
#if [[ -z "$arg" ]]
#if [[ $arg -eq "" ]]
#then
#else
#fi
#echo $arg | awk ' BEGIN { FS=" " } { print $1 }'
FINDIPVAR=$(echo $arg | awk ' BEGIN { FS=" " } { print $1 }')
#FINDREQVAR=$(echo $arg | awk ' BEGIN { FS=" " } { print $2 }')
echo " arg: "$arg
#echo " FINDIPVAR: "$FINDIPVAR
#echo " FINDREQVAR: "$FINDREQVAR
IPPORTCNT=$(echo $FINDIPVAR | awk ' BEGIN { FS="."} END { OFS="."; print $1,$2,$3,$4,$5; } ')
#echo "awk 'BEGIN { ipcnt=0; }  { if ( \$1 == "$FINDIPVAR" ) {ipcnt++; } }  END { print ipcnt; } ' exptipdump"
#echo "awk 'BEGIN { ipcnt=0; }  { if ( \$1 == "$FINDIPVAR" ) {ipcnt++; } }  END { print ipcnt; } ' exptipdump"

#echo " SYNFINREQ: "$SYNFINREQ
#echo " PUSHREQ: "$PUSHREQ
IPPORTCNT=$IPPORTCNT"."$(awk 'BEGIN { ipcnt=0; }  { if ( $1 == "'$FINDIPVAR'" ) {ipcnt++; } }  END { print ipcnt; } ' exptipdump)
IPPORTCNT=$IPPORTCNT"."$(sed -n '/'"$FINDIPVAR"'  \[F\.\],/p' exptipdump | wc -l)
IPPORTCNT=$IPPORTCNT"."$(sed -n '/'"$FINDIPVAR"'  \[P\.\],/p' exptipdump | wc -l)
#echo " IPPORTCNT: "$IPPORTCNT
#echo $IPPORTCNT | awk ' BEGIN { FS="."} END { OFS="."; print "IP: " $1,$2,$3,$4 " \t PORT: " $5 " \t REQ: " $6; } ' >> reporttcpdump.txt
echo $IPPORTCNT | awk ' BEGIN { FS="."} END { OFS="."; print "IP: " $1,$2,$3,$4 "        PORT: " $5 "      REQ: " $6 "          SYN/FIN REQ : " $7 "      PUSH REQ : "$8; } '  >> reporttcpdump.txt
#echo -n " SYN/FIN REQ : "$SYNFINREQ
#echo "\t PUSH REQ : "$PUSHREQ
done
IFS=$ORIFS

exit 0
