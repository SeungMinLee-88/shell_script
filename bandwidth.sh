#!/bin/bash -x
# sar -n DEV로 인터페이스의 대역폭을 모니터링한다.
REPORTTYPE=$1
INTERVAL=$2
ROTATE=$3
GREPIFACE=$4
# 인터페이스 전체인지 선택된 인터페이스인지 구분
if [[ $REPORTTYPE == "ALL" ]]
then
sar -n DEV $INTERVAL $ROTATE | sed -n $GREPIFACE > bandwidth.txt
elif [[ ${IFACELIST[$ADRINTERFACE]} != "ALL" ]]
then
sar -n DEV $INTERVAL $ROTATE | sed -n $GREPIFACE > bandwidth.txt
fi
