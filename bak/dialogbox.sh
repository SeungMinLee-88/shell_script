#!/bin/bash
VALUES=($(dialog  --stdout --title "My input box" --clear \
--form "\nDialog Sample Label and Values" 25 60 16 \
"range of start port:" 1 1 "" 1 25 10 4 \
"range of end port" 2 1 "" 2 25 10 4

--radiolist "choice config menu" 20 51 4 \
        "adduser" "" ON \
))




echo ${#VALUES[*]}

echo ${VALUES[0]}
echo ${VALUES[1]}
echo ${VALUES[2]}
if [ ${#VALUES[*]} -eq "0" ] || [[ ${VALUES[0]} = "" ]] || [[ ${VALUES[1]} = "" ]]
then
echo "invalid value input"
else
echo "process"
fi