#!/bin/bash
# -x
trap "exit 0" 0 1 2 24
ORIFS=$IFS
tempfile=tcpdump.txt
if [ -f "tcpdump.txt" ]
then
yes | rm -i tcpdump.txt
fi

INTERFACE=$1
INTERVAL=$2
ROTATE=$3
let TOTALTIME=$INTERVAL*$ROTATE
CNTVAL=1
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
FINDIPVAR=$(echo $arg | awk ' BEGIN { FS=" " } { print $1 }')
IPPORTCNT=$(echo $FINDIPVAR | awk ' BEGIN { FS="."} END { OFS="."; print $1,$2,$3,$4,$5; } ')
IPPORTCNT=$IPPORTCNT"."$(awk 'BEGIN { ipcnt=0; }  { if ( $1 == "'$FINDIPVAR'" ) {ipcnt++; } }  END { print ipcnt; } ' exptipdump)
IPPORTCNT=$IPPORTCNT"."$(sed -n '/'"$FINDIPVAR"'  \[F\.\],/p' exptipdump | wc -l)
IPPORTCNT=$IPPORTCNT"."$(sed -n '/'"$FINDIPVAR"'  \[P\.\],/p' exptipdump | wc -l)
echo $IPPORTCNT | awk ' BEGIN { FS="."} END { OFS="."; print "IP: " $1,$2,$3,$4 "        PORT: " $5 "      REQ: " $6 "          SYN/FIN REQ : " $7 "      PUSH REQ : "$8; } '  >> reporttcpdump.txt
done

IFS=$ORIFS
exit 0
