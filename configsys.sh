#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
# trap 을 통해 system signal을 캐치 하여 exit 0(정상종료코드)
trap "exit 0" 0 1 2 24
SETCONFIG=
#시스템 구성 옵션을 입력받는 함수
function CONFIGSELECT()
{
#리턴 값을 변수에 할당
#--stdout은 결과값을 표준출력에 출력한다는 의미이다 dialog는 디폴트로 결과 값이 표준에러(FD 2)로 리턴된다
#혹은 exec 3>&1 exec 1>&2 exec 2>&3 통해 표준에러가 표준출력으로 표준출력은 표준에러를 가리키도로 I/O 재지향한다.
#작업 완료 후 반드시 반대 순서로 FD 복구 후 exec 1>&3-(표준출력을 백업된 3번 FD로 복구 후 3번 FD 닫음)
SETCONFIG=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice config menu" 20 51 4 \
        "ADD USER" "" ON \
        "CHECK/FIX VULNERABILITY" "" off \
        "SET FIREWALL" "" off \
        "EXIT"  "" off)
}
#사용자를 추가하는 함수
function SETUSER()
{
USERVALUES=($(dialog  --stdout --title "Make User" --clear \
--form "\nPlease Input Username and User password" 25 60 16 \
"Username:" 1 1 "" 1 15 30 30 \
"Password:" 2 1 "" 2 15 30 30))
#결과 값을 변수에 저장하고 정상코드(0)인지 여부에 따라 변수에 값 할당
RETVAL=$?

SETUSERLT=
#if 문에 [[]] 를 사용하는 이유는 -ne, -eq 등의 비교 연산자와 <, > 등의 논리 연산자와 || && 구문을 사용하기 위함, -eq 등의 연산은 정수 비교이다 -ne "0"은 문자열 비교 처럼 보이지만 정수 비교이다.
if [[ $RETVAL -ne "0" ]]
then
SETUSERLT="select cancel"
fi
}
#무한 루프
while true
do
#시스템 설정 값을 선택하는 함수 실행
CONFIGSELECT
case $SETCONFIG in
  EXIT)
  break
    ;;
  "ADD USER")
      while true
      do
          SETUSER
                  if [[ $SETUSERLT = "select cancel" ]]
                  then
				  #취소룰 선택하면 경고창 띄우고 break
                    dialog --title --stdout "ADD USER" --clear --msgbox "select cancel" 10 30
                    break
                  else
						#유효성을 검사 continue로 while 루프를 재반복
                        if [[ ${#USERVALUES[*]} -eq "0" ]] || [[ ${USERVALUES[0]} = "" ]] || [[ ${USERVALUES[1]} = "" ]]
                        then
                          dialog --title --stdout "error cause" --clear --msgbox "INVALID VALUE INPUT" 10 30
                          continue
                        else
							#sed 명령어로 passwd 파일에 입력한 유저가 존재 하는지 확인하고 그 결과를 or list로 awk 명령으로 넘긴다
							# -F로 필드 값 구분자를 ":" 설정하고 결과 값을 배열로 저장
							# 배열은 val=(a b c d) 형태로 초기화 및 값 할당 가능
                          USEREXIST=$(sed -n "/${USERVALUES[0]}/p" /etc/passwd | awk -F: '{ print $1 }')
                            if [[ ${USEREXIST} != "" ]]
                            then
                              dialog --title --stdout "ADD USER" --clear --msgbox "${USERVALUES[0]} ALEADY EXITS USER" 10 30
							  #배열 값 ${USERVALUES[0]} 이렇게 호출
                              echo "${USERVALUES[0]} ALEADY EXITS USER"
                              continue
                            else
                              useradd ${USERVALUES[0]}
                                if [[ $USERADDRLT -ne "0" ]]
                                then
                                  dialog --title --stdout "ADD USER" --clear --msgbox "USER ADD FAIL" 10 30
                                else
								# passwd 명령어의 입력 값을 echo된 텍스트로 받는다. 
                                  echo ${USERVALUES[1]} | passwd ${USERVALUES[0]} --stdin
                                  dialog --title --stdout "ADD USER" --clear --msgbox "${USERVALUES[0]} USER ADD SUCCESS" 10 30
                                  break
                                fi
                            fi
                        fi
                  fi
      done
          ;;
  "CHECK/FIX VULNERABILITY")
    COUNT=0
    VULCHECKRLT=
	#$() 명령어 실행 결과를 리턴 받는다
	# vulcheck.sh : 취약점을 체크하는 스크립트 / vulfix.sh : 취약점을 조치하는 스크립트
    VULCHECKRLT=$(sh vulcheck.sh)
    VULFIXRLT=
    VULFIXRLT=$(sh vulfix.sh)
    while [ $COUNT != 100 ]
    do
    COUNT=$(expr $COUNT + 25)
    echo $COUNT
    sleep 1
	#dialog의 gaouge 옵션 사용하여 게이지 상승 UI 표시하는 옵션이고 while문에서의 변수를 게이지 숫자로 표시
    done | dialog --title "CHECK/FIX VULNERABILITY." --gauge "Check and Fix VULNERABILITY" 20 70 0
    dialog --title --stdout "CHECK/FIX VULNERABILITY" --clear --msgbox "VULNERABILITY Check Success" 10 30
      if [[ $VULCHECKRLT -ne "0" ]]
      then
      dialog --title --stdout "CHECK/FIX VULNERABILITY" --clear --msgbox "VULCHECKRLT SCRIPT OCCUR \"$VULCHECKRLT\" ERROR" 10 30
      fi
      if [[ $VULCHECKRLT -ne "0" ]]
      then
      dialog --title --stdout "CHECK/FIX VULNERABILITY" --clear --msgbox "VULCHECKRLT SCRIPT OCCUR \"$VULCHECKRLT\" ERROR" 10 30
      fi
  continue
    ;;
  "SET FIREWALL")
    SETFIRWALLRLT=
	#firewalld : 데몬을 설정하는 스크립트
    SETFIRWALLRLT=$(sh firewallconf.sh)
	#스크립트 리턴 값을 체크하여 처리
	# 참고 if문에서 [[]]을 사용해야 ||, && 등 사용가능하다
      if [[ $SETFIRWALLRLT = "firewall service is not running" ]] || [[ $SETFIRWALLRLT -ne "0" ]]
      then
      dialog --title --stdout "SET FIREWALL" --clear --msgbox "FIREWALL SCRIPT OCCUR \"$SETFIRWALLRLT\" ERROR" 10 30
      fi
    continue
    ;;
  * )
  break
  ;;
esac
done
exit 0
