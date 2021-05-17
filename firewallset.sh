#!/bin/bash
# 실제 firewalld 데몬을 설정하는 스크립트이다.
# 첫번째 명령줄 인자를 변수에 할당하여 어떤 처리를 할지 분기한다.
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
	  # firewalld 데몬을 재구동 시에 표준출력, 표준에러 모두 출력하지 않기 위해 /dev/null로 보낸다.
      firewall-cmd --reload 1>/dev/null 2>/dev/null
      firewall-cmd --set-default-zone=$ZONENAME 1>/dev/null 2>/dev/null
      echo $SETRESULT
      exit 0
    fi
exit 0
fi
# rich-rule을 설정하는 부분
if [[ $SETCONFIG == "RICH RULE" ]]
then
  ZONENAME=
  RICHCONFIGS=($2 $3 $4 $5)
ZONENAME=$5
  if [[ ${RICHCONFIGS[3]} != "" ]]
  then
      # rich-rule을 설정하고 그 결과 값을 변수에 할당
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
# 사용자 정의 포트를 설정하는 부분
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
# 서비스를(http, sftp 등)을 설정하는 부분
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