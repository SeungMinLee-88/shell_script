#!/bin/bash
#rich rule
#echo "1st val : " $1
#echo "2st val : " $2
#echo "3st val : " $3
#echo "4st val : " $4
#echo "5st val : " $5
#echo "\$* val : " $*

setconfig=$1
setresult=
if [[ $setconfig == "make zone" ]]
then
zonename=$2
setresult=$(firewall-cmd --permanent --new-zone=$zonename 2>&1)
cmdresult=$?
    if [[ $cmdresult -ne "0" ]]
    then
      #echo "setresult : "
      echo $setresult | awk '{ print $2 }'
      exit 0
    else
      #echo "setresult : "
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      firewall-cmd --set-default-zone=$zonename 1>/dev/null 2>/dev/null
      echo $setresult
      exit 0
    fi
#firewall-cmd --reload
exit 0
fi
if [[ $setconfig == "rich rule" ]]
then
  zonename=
  #echo "set rich rule"
  richconfigs=($2 $3 $4 $5)
#echo "richconfigs[0] : "  ${richconfigs[0]}
#echo "richconfigs[1] : "  ${richconfigs[1]}
#echo "richconfigs[2] : "  ${richconfigs[2]}
#echo "richconfigs[3] : "  ${richconfigs[3]}
zonename=$5
  if [[ ${richconfigs[3]} != "" ]]
  then

    #echo "with source address"
    #echo "firewall-cmd --zone=$zonename --permanent --add-rich-rule="rule family="ipv4" source address="${richconfigs[2]}" port port="${richconfigs[0]}-${richconfigs[1]}" protocol="tcp" accept""

      setresult=$(firewall-cmd --zone=$zonename --permanent --add-rich-rule="rule family="ipv4" source address="${richconfigs[2]}" port port="${richconfigs[0]}-${richconfigs[1]}" protocol="tcp" accept" 2>/dev/null)
      cmdresult=$?
      #echo "setresult : "$setresult " cmdresult : "$cmdresult

        if [[ $cmdresult -ne "0" ]]
        then
          #echo "setresult : "
          systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
          echo $setresult | awk '{ print $2 }'
          exit 0
        else
          #echo "setresult : "

          echo $setresult
          exit 0
        fi
  elif [[ ${richconfigs[0]} != "" && ${richconfigs[1]} != "" && ${richconfigs[2]} != "" && ${richconfigs[3]} = "" ]]
  then

    #echo "without source address"
    #echo "firewall-cmd --zone=$zonename --add-rich-rule="rule family="ipv4" port port="${richconfigs[0]}-${richconfigs[1]}" protocol="tcp" accept""

      setresult=$(firewall-cmd --zone=$zonename --permanent --add-rich-rule="rule family="ipv4" port port="${richconfigs[0]}-${richconfigs[1]}" protocol="tcp" accept" 2>/dev/null)
      cmdresult=$?
      #echo "setresult : "$setresult " cmdresult : "$cmdresult
        if [[ $cmdresult -ne "0" ]]
        then
          #echo "setresult : "
          systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
          echo $setresult | awk '{ print $2 }'
          exit 0
        else
          #echo "setresult : "

          echo $setresult
          exit 0
        fi
  fi
fi

if [[ $setconfig == "custom port" ]]
then
zonename=$2
setport=$3
#echo "firewall-cmd --permanent --add-port=$setport/tcp --zone=$zonename"
setresult=$(firewall-cmd --permanent --add-port=$setport/tcp --zone=$zonename 2>&1)
cmdresult=$?
    if [[ $cmdresult -ne "0" ]]
    then
      #echo "setresult : "
      echo $setresult | awk '{ print $2 }'
      exit 0
    else
      #echo "setresult : "
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      echo $setresult
      exit 0
    fi
#firewall-cmd --reload
exit 0
fi

if [[ $setconfig == "serviceset" ]]
then
zonename=$2
setservice=$3
#echo "firewall-cmd --permanent --add-port=$setport/tcp --zone=$zonename"
setresult=$(firewall-cmd --permanent --add-service=$setservice --zone=$zonename 2>&1)
cmdresult=$?
    if [[ $cmdresult -ne "0" ]]
    then
      #echo "setresult : "
      echo $setresult | awk '{ print $2 }'
      exit 0
    else
      #echo "setresult : "
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      echo $setresult
      exit 0
    fi
#firewall-cmd --reload
exit 0
fi

if [[ $setconfig == "deleteconfig" ]]
then
  #echo "deleteconfig!!"

zonename=$2
conftype=$3
confval=$4
#echo "firewall-cmd --permanent --remove-$conftype=$confval --zone=$zonename"
if [[ $conftype == "rich-rule" ]]
then
setresult=$(firewall-cmd --permanent --remove-$conftype="$confval" --zone=$zonename 2>&1)
else
setresult=$(firewall-cmd --permanent --remove-$conftype=$confval --zone=$zonename 2>&1)
fi
cmdresult=$?
#echo "setresult : "$cmdresult
    if [[ $cmdresult -ne "0" ]]
    then
      #echo "setresult : "
      echo $setresult | awk '{ print $2 }'
      exit 0
    else
      #echo "setresult : "
      #firewall-cmd --reload 1>/dev/null 2>/dev/null
      systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
      echo $setresult
      exit 0
    fi
#firewall-cmd --reload
exit 0
fi

if [[ $setconfig == "deletezone" ]]
then
  #echo "deleteconfig!!"
zonename=$2
#echo "firewall-cmd --permanent --delete-zone=$zonename"
setresult=$(firewall-cmd --permanent --delete-zone=$zonename 2>&1)
cmdresult=$?
#echo "setresult : "$cmdresult
    if [[ $cmdresult -ne "0" ]]
    then
      #echo "setresult : "
      #echo $setresult | awk '{ print $2 }'
      exit 0
    else
      #echo "setresult : "
      #firewall-cmd --reload 1>/dev/null 2>/dev/null
      systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
      echo $setresult
      exit 0
    fi
#firewall-cmd --reload
exit 0
fi

echo "setport : "$setport
echo ${#richconfigs[*]}
echo ${richconfigs[0]}
echo ${richconfigs[1]}
echo ${richconfigs[2]}