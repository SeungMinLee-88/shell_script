#!/bin/bash -x

echo "1 : "$1
echo "2 : "$2
echo "3 : "$3
echo "4 : "$4
REPORTTYPE=$1
INTERVAL=$2
ROTATE=$3
GREPIFACE=$4
echo "GREPIFACE :"$GREPIFACE

    if [[ $REPORTTYPE == "ALL" ]]
    then
      echo "ALLLLLLLLLLLLLLLLLLLLLLLLLL"
    #banwidthcommand="sar -n DEV "$INTERVAL" "$ROTATE" | sed -n "$ALLIFACELIST" > bandwidth.txt"
    sar -n DEV $INTERVAL $ROTATE | sed -n $GREPIFACE > bandwidth.txt
    elif [[ ${IFACELIST[$ADRINTERFACE]} != "ALL" ]]
    then
      echo "NOT ALLLLLLLLLLLLLLLLLLLLLLLLLL"
    #banwidthcommand="sar -n DEV $INTERVAL $ROTATE | sed -n -e '/${IFACELIST[$ADRINTERFACE]}/p' > bandwidth.txt"
    sar -n DEV $INTERVAL $ROTATE | sed -n $GREPIFACE > bandwidth.txt
    fi
