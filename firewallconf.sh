#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
TEMPFILE=portset
#입력 필드 구분자인 $IFS를 백업 해둔다
ORIFS=$IFS
#trap으로 system signal을 캐치하여 파일을 삭제하고 인터럽트 메시지를 표시한다.
trap 'rm -f "$TEMPFILE"' 0 1 2 24
trap "echo \"find interrupt\" ; exit 0" 0 1 2 24
TEMPRULEFILE=richrules.txt
trap 'rm -f "$TEMPRULEFILE" ; exit 0' 0 1 2 24
#firewalld 데몬의 구동을 확인한다 표준출력을 /dev/null로 보내 표시 하지 않는다 상태 체크 후 구동중이면 정상코드(0)리턴되며 구동중이지 않으면 비정상코드(128 등)을 리턴한다.
systemctl status firewalld.service 1>/dev/null
CHKSRV=$?
# [[]] 을 사용하는 이유는 || && 등을 사용할 수 있고 크기비교도 가능하기 때문 <, >
if [[ $CHKSRV != "0" ]]
then
echo "firewall service is not running"
exit 0
fi
COUNT=0;
#firewalld 데몬의 zone name을 입력받는 함수.
function MAKEZONE()
{
#입력 정상 체크
ZONENAME=$(dialog --stdout --title "Input zone Name" --clear \
        --inputbox "Please input zone name" \
        16 51 ""
        )
#입력 정상 체크
RETVAL=$?
if [[ $RETVAL -ne "0" ]]
then
ZONENAME="select cancel"
fi

}
#rich-rule의 설정값을 입력받는 함수이다.
function SETRICHRULE()
{
SETRICHRULERLT=0
#리턴관 값을 파일로 저장한다.
dialog  --stdout --title "My input box" --clear \
--form "\nDialog Sample Label and Values" 25 60 16 \
"start port:" 1 1 "" 1 25 10 4 \
"end port" 3 1 "" 3 25 10 4 \
"source address:" 5 1 "" 5 18 18 15 > $TEMPFILE
RETVAL=$?
if [[ $RETVAL -ne "0" ]]
then
SETRICHRULERLT="select cancel"
fi

NUM=0
while read ARG
do

RICHCONFIGS[$NUM]=$ARG
#(()) 산술식 테스트 구문이다 let 으로도 가능
(( NUM++ ))
done < $TEMPFILE
}
# 사용자 정의 포트를 입력 받는 황수
function CUSTOMPORT()
{
CUSTOMPORTRLT=0
CUSTOMPORT=$(dialog --stdout --title "CUSTOM PORT input" --clear \
        --inputbox "Please input port value" \
        16 51 ""
        )
RETVAL=$?
if [[ $RETVAL -ne "0" ]]
then
CUSTOMPORTRLT="select cancel"
fi
}
# firewalld 데몬을 설정하는 메인 함수 이다.
function SETFIREWALLD()
{
# 명령줄 인자를 변수에 저장한다.
SELECTEDZONE=$1
while true
do
SETPORT=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice service or range(selected zone:$SELECTEDZONE)" 20 60 4 \
        "REMOVE CONFIG"  "REMOVE CONFIG" ON \
        "CUSTOM PORT"  "CUSTOM PORT" off \
        "RICH RULE"  "ex)30-40 port range, set source IP" off \
        "http"  "80" off \
        "https"  "443" off \
        "ftp"  "20/21" off \
        "telnet"  "23" off \
        "ssh"  "22" off \
        "EXIT"  "EXIT" off)
SETFIREWALLDRLT=$?

case $SETFIREWALLDRLT in
  1)
    echo "cancel"
    dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
    break
  ;;
  0)
    dialog --title --stdout "Check choice config" --clear \
            --yesno "Is \"$SETPORT\" your choice?" 10 30
      FIREWALLCHKCONFIG=$?
	  #case문으로 선택한 메뉴에 따라 분기한다.
      case $FIREWALLCHKCONFIG in
      0)
          case $SETPORT in
          "RICH RULE")
              while true
              do
			    #rich-rule 함수를 호출
                SETRICHRULE
                  # 시작 포트와 끝 포트를 정규표혁식으로 무결성 검사한다. 정규 표현식에 계속 쓰이는 "\"은 이스케이프 문자일 수도 있다.
				  STARTPORTCHK=$(echo "${RICHCONFIGS[0]}" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)
                  ENDPORTCHK=$(echo "${RICHCONFIGS[1]}" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)
				  # if 문안의 문자열 비교를 "=" 사용했다 "==" 독 가능
                  if [[ $SETRICHRULERLT = "select cancel" ]]
                  then
                    dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
                    break
                  else
				      # 배열의 크기는 ${#RICHCONFIGS[*]} 이런 형식으로 확인 할 수 있다.
                      if [[ ${#RICHCONFIGS[*]} -eq "3" ]]
                      then
					    # IP 주소 형식의 입력 값 무결성을 검사하는 정규 표현식
                        SRCIPCHK=$(echo "${RICHCONFIGS[2]}" | grep -o "\(^[1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\)" | wc -l)
                              if [[ ${RICHCONFIGS[2]} != "" && SRCIPCHK -ne "1" ]]
                                then

                                  dialog --title --stdout "RICH RULE" --clear --msgbox "source ip not valid" 10 30
                                  continue
                              elif [[ ${RICHCONFIGS[0]} = "" || ${RICHCONFIGS[1]} = "" || STARTPORTCHK -eq "0" || ENDPORTCHK -eq "0" ]]
                              then
                                  dialog --title --stdout "RICH RULE" --clear --msgbox "port value is not valid" 10 30
                                  continue
                              else
							      # firewallset.sh 스크립트에 인자를 전달하여 firewalld 데몬을 설정한다.
                                  GETRESULT=$(sh firewallset.sh "$SETPORT" "${RICHCONFIGS[0]}" "${RICHCONFIGS[1]}" "${RICHCONFIGS[2]}" "$SELECTEDZONE")

                                    if [[ $GETRESULT != "success" ]]
                                    then
                                      dialog --title --stdout "RICH RULE" --clear --msgbox "\"$GETRESULT\" error is caused" 20 50
                                    else
                                    dialog --title --stdout "RICH RULE" --clear --msgbox "RICH RULE config is success" 20 50
                                    break
                                    fi
                                  sleep 1
                              fi
                      else
                        sh firewallset.sh $SETPORT
                      fi
                  fi
              done
          ;;
          "CUSTOM PORT")
            while true
            do
              CUSTOMPORT
              if [[ $CUSTOMPORTRLT = "select cancel" ]]
              then
                dialog --title --stdout "CUSTOM PORT" --clear --msgbox "select cancel" 10 30
                break
              else
			     # 포트 입력값의 무결성 검사
                 SETPORTCHK=$(echo "$CUSTOMPORT" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)
                  if [[ $SETPORTCHK -ne "1" ]]
                  then
                    dialog --title --stdout "CUSTOM PORT" --clear --msgbox "port value is not valid" 10 30
                    continue
                  fi
                      if [[ $CUSTOMPORT = "" ]]
                      then
                        dialog --title --stdout "CUSTOM PORT" --clear --msgbox "invalid ZONENAME input" 10 30
                        continue
                      else
					  # yesno 형식의 dialog UI를 통해 입력값이 올바른지 체크
                      dialog --title --stdout "Check input port" --clear \
                            --yesno "Is \"$CUSTOMPORT\" your input port?" 10 30
                          case $? in
                          0)
						    # 서브 스크립트의 실행 결과를 변수에 저장한다.
                            GETRESULT=$(sh firewallset.sh "$SETPORT" "$SELECTEDZONE" "$CUSTOMPORT")

                            if [[ $GETRESULT != "success" ]]
                            then
                              dialog --title --stdout "CUSTOM PORT" --clear --msgbox "\"$GETRESULT\" error is caused" 10 30
                            else
                              dialog --title --stdout "CUSTOM PORT" --clear --msgbox "\"$CUSTOMPORT\" port is set" 10 30
                            break
                            fi
                          ;;
                          1)
                          continue
                          ;;
                          esac
                      fi
              fi
            done
          ;;
        "REMOVE CONFIG")
              REMOVEZONEORCONFIG "REMOVE CONFIG" $SELECTEDZONE
			  # 무결성 검사.
              SETPORTCHK=$(echo "$CUSTOMPORT" | grep -o "\(^[^0]\{1,1\}[0-9]\{0,4\}\)" | wc -l)
                if [[ $FUNCRLT == "cancel" ]]
                then
                  dialog --title --stdout "REMOVE CONFIG" --clear --msgbox "select cancel" 10 30
                  sleep 1
                  continue
                elif [[ $FUNCRLT == "nothingset" ]]
                then
                  continue
                elif [[ $FUNCRLT != "cancel" ]]
                then
				  # echo의 출력 결과를 awk 명령에 전달하고 awk 명령의 입력값 구분을 -F 옵션으로 "|"로 변경한다. 구분자를 통해 구분된 값들을 변수에 저장한다.
                  CONFIGVAL=$(echo "$DELETECONFIG" | awk 'BEGIN { FS="|" } { print $1 }')
                  CONFIGTYPE=$(echo "$DELETECONFIG" | awk 'BEGIN { FS="|" } { print $2 }')
                  GETRESULT=$(sh firewallset.sh "DELETECONFIG" "$SELECTEDZONE"  "$CONFIGTYPE" "$CONFIGVAL")
                      if [[ $GETRESULT != "success" ]]
                      then
                        dialog --title --stdout "REMOVE CONFIG" --clear --msgbox "\"$GETRESULT\" error is caused" 10 30
                      else
                        dialog --title --stdout "REMOVE CONFIG" --clear --msgbox "Delete \"$CONFIGTYPE\" success" 10 30
                        continue
                      fi
                  continue
                  GETRESULT=$(sh firewallset.sh "$SETCONFIG" "$ZONENAME")
                  dialog --title --stdout "REMOVE CONFIG" --clear --msgbox "REMOVE CONFIG success" 10 30
                  continue
                fi
          ;;
        "EXIT")
                break
          ;;
          *)
                  servicename=$SETPORT
                  GETRESULT=$(sh firewallset.sh "SERVICESET" "$SELECTEDZONE" "$servicename")
                  if [[ $GETRESULT != "success" ]]
                  then
                    dialog --title --stdout "SERVICE SET" --clear --msgbox "\"$GETRESULT\" error is caused" 10 30
                  else
                    dialog --title --stdout "SERVICE SET" --clear --msgbox "\"$servicename\" service is set" 10 30
                  continue
                  fi
          ;;
          esac
      ;;
      1)
        continue
      ;;
      esac
  ;;
  esac
done
}
# firewalld 데몬 설정 대상 zone을 선택하는 함수이다.
function SELECTZONE()
{
# zone의 리스트를 함수에 저장한다 array=("1" "2" "3") 이렇게 함수 초기화
ZONEVAR=($(firewall-cmd --permanent --get-zones))
MENUVAR="${ZONEVAR[0]} ${ZONEVAR[0]} off"
unset ZONEVAR[0]
for ARG in ${ZONEVAR[@]}
do
MENUVAR="$MENUVAR $ARG $ARG off"
done
SETCONFIG=$(dialog --stdout --clear --title "Select zone or make zone" \
    --radiolist "zone list" 20 60 4  \
    "REMOVE ZONE" "delete custom zone" on \
    "MAKE ZONE" "make zone and change default zone" off \
    $MENUVAR \
    "EXIT"  "EXIT" off)
    RETVAL=$?

if [[ $RETVAL -ne "0" ]]
then
  SETCONFIG="cancel"
fi
}
# zone의 삭제와 zone에 할당된 설정을 삭제하는 함수
function REMOVEZONEORCONFIG()
{
CONFIG="$1"
FUNCRLT=
while true
do
case $CONFIG in
  "REMOVE ZONE")
    MENUZONE=
    REMOVEZONE=
	# zone 리스트를 awk로 명령으로 전달하고 awk는 -f 옵션을 주어 파일로 실행한다.
    ZONELIST=($(firewall-cmd --get-zones | awk -f zonelist.awk))
      for ARG in ${ZONELIST[@]}
      do
      MENUZONE="$MENUZONE $ARG $ARG off"
      done
        REMOVEZONE=$(dialog --stdout --clear --title "REMOVE ZONE" \
        --radiolist "zone list" 20 60 4  \
        $MENUZONE)
        RETVAL=$?

          if [[ $RETVAL -eq 0 && -n "$REMOVEZONE" ]]
          then
            FUNCRLT="succes"
            break
          elif [[ $RETVAL -eq 0 && -z "$REMOVEZONE" ]]
          then
            dialog --title --stdout "dialog" --clear --msgbox "please select zone" 10 30
            continue
          elif [[ $RETVAL -ne 0 ]]
          then
            FUNCRLT="cancel"
          fi
      break
  ;;
  "REMOVE CONFIG")
    SELECTEDZONE=$2
	# zone에 설정된 값을 삭제한다 --permanent는 영구 적용된 설정을 불러오기위함 2>/dev/null은 표준 에러를 출력하지 않기 위해
    SERVICES=($(firewall-cmd --permanent --list-services --zone=$SELECTEDZONE 2>/dev/null))
    PORTS=($(firewall-cmd --permanent --list-ports --zone=$SELECTEDZONE 2>/dev/null))
    firewall-cmd --permanent --list-rich-rules --zone=$SELECTEDZONE > $TEMPRULEFILE
    cat $TEMPRULEFILE
    ARRNUM=2
    SERVICESLEN=${#SERVICES[0]}
    PORTSLEN=${#PORTS[0]}
	# expr 명령으로 파일의 라인수를 구하고 그 값을 변수에 할당한다.
    RICHRULES=$(expr length "$(cat $TEMPRULEFILE)")

      if [[ $SERVICESLEN -eq 0 && $PORTSLEN -eq 0 && $RICHRULES -eq 0 ]]
      then
        dialog --title --stdout "REMOVE CONFIG" --clear --msgbox "nothing is set" 10 30
        FUNCRLT="nothingset"
        break
      fi
	    # 입력 구분자를 new line(\n)으로 설정한다.  new line을 입력 구분자로 설정하려면 
		#IFS="
		#" 이렇게 하거나 $'를 붙여 이스케이프 시켜야 한다.
        IFS=$'\n'
		# dialog의 메뉴를 배열에 할당시켜 배열을 for 문으로 출력하며 메뉴를 보여준다, (()) 산술식 확장이다.
          DELETECONFIG=$(dialog --clear --stdout --title "choice service or port" \
          --radiolist "(selectd zone:$SELECTEDZONE)" 20 80 4 \
            $(for ARG in ${SERVICES[@]}
            do
            echo "$ARG|service"
            echo " "
            echo "off"
            (( ARRNUM++ ))
                  done) \
                  $(for ARG in ${PORTS[@]}
                  do
            echo "$ARG|port"
            echo " "
            echo "off"
            (( ARRNUM++ ))
                  done) \
                  $(for ARG in $(cat $TEMPRULEFILE)
                  do
            echo "$ARG|rich-rule"
            echo " "
            echo "off"
            (( ARRNUM++ ))
            done))
            RETVAL=$?
			# 입력 구분자를 백업된 값으로 복원한다.
            IFS=$ORIFS
              if [[ $RETVAL -eq 0 && -n "$DELETECONFIG" ]]
              then

                FUNCRLT="succes"
                break
              elif [[ $RETVAL -eq 0 && -z "$DELETECONFIG" ]]
              then
                dialog --title --stdout "dialog" --clear --msgbox "please select config" 10 30
                continue
              elif [[ $RETVAL -ne 0 ]]
              then
                echo "cancel selected"
                FUNCRLT="cancel"
              fi
        break
  ;;
esac
done
}
# 가장 처음 실행되는 프로세스이며 무한 루프를 통해 exit 요청이 있을 시점까지 반복한다.
while true
do
SELECTZONE
case $SETCONFIG in
  "cancel")
  dialog --title --stdout "My first dialog" --clear --msgbox "select cancel" 10 30
  echo "Good Bye~"
  break
    ;;
  "MAKE ZONE")
        while true
        do
          MAKEZONE
          RETVAL=$?
            if [[ $ZONENAME = "" ]]
            then
              dialog --title --stdout "MAKE ZONE" --clear --msgbox "invalid zone name input" 10 30
              continue
            elif [[ $ZONENAME = "select cancel" ]]
            then
              dialog --title --stdout "MAKE ZONE" --clear --msgbox "select cancel" 10 30
              break
            else
              dialog --title --stdout "MAKE ZONE" --clear \
                        --yesno "is \"$ZONENAME\" your input zone name?" 10 30
                case $? in
                0)
                  GETRESULT=$(sh firewallset.sh "$SETCONFIG" "$ZONENAME")
                    if [[ $GETRESULT != "success" ]]
                    then
                      dialog --title --stdout "MAKE ZONE" --clear --msgbox "\"$GETRESULT\" error is caused!" 10 30
                    else
                      dialog --title --stdout "MAKE ZONE" --clear --msgbox "zone \"$ZONENAME\" is maked" 10 30
                      break
                    fi
                ;;
                1)
                  continue
                ;;
                esac
            fi
        done
  continue
  ;;
  "REMOVE ZONE")
        REMOVEZONEORCONFIG "REMOVE ZONE"
            if [[ $FUNCRLT == "cancel" ]]
            then
              echo "cancel selected"
              dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
              continue
            elif [[ $FUNCRLT != "cancel" ]]
            then
              GETRESULT=$(sh firewallset.sh "REMOVEZONE" "$REMOVEZONE")

                if [[ $GETRESULT != "success" ]]
                then
                  dialog --title --stdout "REMOVE ZONE" --clear --msgbox "\"$GETRESULT\" error is caused" 10 30
                else
                  dialog --title --stdout "REMOVE ZONE" --clear --msgbox "remove zone success" 10 30
                  continue
                fi
            continue
            fi
  continue
  ;;
  "EXIT" )
    break
  ;;
  * )
    SETFIREWALLD $SETCONFIG
    continue
  ;;
esac
done
exit 0


