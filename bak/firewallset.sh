#!/bin/bash
SETCONFIG=$1
SETRESULT=
if [[ $SETCONFIG == "MAKE ZONE" ]]
then
ZONENAME=$2
SETRESULT=$(firewall-cmd --permanent --new-zone=$ZONENAME 2>&1)
CMDRESULT=$?
    if [[ $CMDRESULT -ne "0" ]]
    then
      echo $SETRESULT | awk '{ print $2 }'
      exit 0
    else
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      firewall-cmd --set-default-zone=$ZONENAME 1>/dev/null 2>/dev/null
      echo $SETRESULT
      exit 0
    fi
exit 0
fi
if [[ $SETCONFIG == "RICH RULE" ]]
then
  ZONENAME=
  RICHCONFIGS=($2 $3 $4 $5)
ZONENAME=$5
  if [[ ${RICHCONFIGS[3]} != "" ]]
  then
      SETRESULT=$(firewall-cmd --zone=$ZONENAME --permanent --add-rich-rule="rule family="ipv4" source address="${RICHCONFIGS[2]}" port port="${RICHCONFIGS[0]}-${RICHCONFIGS[1]}" protocol="tcp" accept" 2>/dev/null)
      CMDRESULT=$?
        if [[ $CMDRESULT -ne "0" ]]
        then
          firewall-cmd --reload 1>/dev/null 2>/dev/null
          systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
          echo $SETRESULT | awk '{ print $2 }'
          exit 0
        else
          firewall-cmd --reload 1>/dev/null 2>/dev/null
          systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
          echo $SETRESULT
          exit 0
        fi
  elif [[ ${RICHCONFIGS[0]} != "" && ${RICHCONFIGS[1]} != "" && ${RICHCONFIGS[2]} != "" && ${RICHCONFIGS[3]} = "" ]]
  then
      SETRESULT=$(firewall-cmd --zone=$ZONENAME --permanent --add-rich-rule="rule family="ipv4" port port="${RICHCONFIGS[0]}-${RICHCONFIGS[1]}" protocol="tcp" accept" 2>/dev/null)
      CMDRESULT=$?
        if [[ $CMDRESULT -ne "0" ]]
        then
          firewall-cmd --reload 1>/dev/null 2>/dev/null
          systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
          echo $SETRESULT | awk '{ print $2 }'
          exit 0
        else
          firewall-cmd --reload 1>/dev/null 2>/dev/null
          systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
          echo $SETRESULT
          exit 0
        fi
  fi
fi

if [[ $SETCONFIG == "CUSTOM PORT" ]]
then
ZONENAME=$2
SETPORT=$3
SETRESULT=$(firewall-cmd --permanent --add-port=$SETPORT/tcp --zone=$ZONENAME 2>&1)
CMDRESULT=$?
    if [[ $CMDRESULT -ne "0" ]]
    then
      echo $SETRESULT | awk '{ print $2 }'
      exit 0
    else
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      echo $SETRESULT
      exit 0
    fi
exit 0
fi

if [[ $SETCONFIG == "SERVICESET" ]]
then
ZONENAME=$2
SETSERVICE=$3
SETRESULT=$(firewall-cmd --permanent --add-service=$SETSERVICE --zone=$ZONENAME 2>&1)
CMDRESULT=$?
    if [[ $CMDRESULT -ne "0" ]]
    then
      echo $SETRESULT | awk '{ print $2 }'
      exit 0
    else
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      echo $SETRESULT
      exit 0
    fi
exit 0
fi

if [[ $SETCONFIG == "DELETECONFIG" ]]
then
ZONENAME=$2
CONFTYPE=$3
CONFVAL=$4
if [[ $CONFTYPE == "rich-rule" ]]
then
SETRESULT=$(firewall-cmd --permanent --remove-$CONFTYPE="$CONFVAL" --zone=$ZONENAME 2>&1)
else
SETRESULT=$(firewall-cmd --permanent --remove-$CONFTYPE=$CONFVAL --zone=$ZONENAME 2>&1)
fi
CMDRESULT=$?
    if [[ $CMDRESULT -ne "0" ]]
    then
      echo $SETRESULT | awk '{ print $2 }'
      exit 0
    else
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
      echo $SETRESULT
      exit 0
    fi
exit 0
fi

if [[ $SETCONFIG == "REMOVEZONE" ]]
then

ZONENAME=$2
SETRESULT=$(firewall-cmd --permanent --delete-zone=$ZONENAME 2>&1)
CMDRESULT=$?

    if [[ $CMDRESULT -ne "0" ]]
    then
      exit 0
    else
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      systecmctl restart firewalld.service 1>/dev/null 2>/dev/null
      echo $SETRESULT
      exit 0
    fi
exit 0
fi