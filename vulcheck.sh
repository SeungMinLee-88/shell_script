#!/bin/bash
# 시스템 취약점을 검출하는 스크립트이다.
# trap으로 system signal 발생 시 파일 삭제
trap 'rm -f targetconfig/vulcheckresult.txt; exit' 1 2 15 24
# OS의 주요 버전을 변수에 할당한다.
RHELVER=$(awk '{ print $4 }' /etc/redhat-release | awk -F. '{ print $1 }')
#RHELVER=5
echo > targetconfig/vulcheckresult.txt
CHECKRESULT=targetconfig/vulcheckresult.txt

echo "-------------------------------------SYSTEM VULNERABILITY DETECTED LIST-----------------------------------" > $CHECKRESULT
# -f 파일 테스트 연산자
if [ -f ".system-auth_test.swp" ]
then
yes | rm -i targetconfig/.system-auth_test.swp
fi
if [ -f ".pwquality.conf_test.swp" ]
then
yes | rm -i targetconfig/.pwquality.conf_test.swp
fi
if [ -f ".login.defs_test.swp" ]
then
yes | rm -i targetconfig/.login.defs_test.swp
fi

############################################################ U-02 ############################################################
CHKVALUE=
PWCOMPLEXRLT=
PWCOMPLEXLIST=
if [[ RHELVER -eq "5" ]]
then
  CHKVALUE=("retry=3" "minlen=8" "lcredit=-1" "ucredit=-1" "dcredit=-1" "difok=N")
  echo "***************************************OS VERSION : Linux release $RHELVER***************************************" >> $CHECKRESULT
  element_count=${#CHKVALUE[@]}
  INDEX=0
  while [ "$INDEX" -lt "$element_count" ]
  do

  OUTPUT=
  ex targetconfig/system-auth_test +/${CHKVALUE[$INDEX]}/ -s +'p|q!' 1 > /dev/null
  OUTPUT=$?
    if [ $OUTPUT -eq "1" ]
    then
    PWCOMPLEXRLT="PASSWORD COMPLEXITY : DETECTED\n"

    PWCOMPLEXLIST=$PWCOMPLEXLIST"${CHKVALUE[$INDEX]} IS NOT SET\n"
    elif [ $OUTPUT -eq "0" ]
    then
    PWCOMPLEXLIST=$PWCOMPLEXLIST"${CHKVALUE[$INDEX]} IS SET\n"
    fi
  let "INDEX = $INDEX + 1"
  done
echo "----------------------------------------------------------------------------------------------------------" >> $CHECKRESULT
echo "# U-02 PASSWORD COMPLEXITY" >> $CHECKRESULT
# printf를 사용하는 이유는 \n(new line) 등을 문자로 인식하지 않고 새로운 줄에 내용을 기록하기 위함이다.
printf "$PWCOMPLEXRLT" >> $CHECKRESULT
printf "$PWCOMPLEXLIST" >> $CHECKRESULT
printf "\n" >> $CHECKRESULT
fi
REMARKCHK=
if [[ RHELVER -eq "7" ]]
then
  CHKVALUE=("retry = 3" "minlen = 8" "lcredit = 1" "ucredit = 1" "dcredit = 1" "difok = N")
  echo "***************************************OS VERSION : Linux release $RHELVER***************************************" >> $CHECKRESULT
  element_count=${#CHKVALUE[@]}
  INDEX=0
  while [ "$INDEX" -lt "$element_count" ]
  do
  OUTPUT=
  # ex 명령으로 파일에서 내용을 찾고 그 내용을 awk 명령으로 출력한다.
  REMARKCHK=$(ex targetconfig/pwquality.conf_test +/"${CHKVALUE[$INDEX]}"/ -s +'p|w|q!' | awk '{ print $1 }')

  OUTPUT=$?
    if [ $OUTPUT -eq "1" ]
    then
    PWCOMPLEXRLT="PASSWORD COMPLEXITY : DETECTED\n"
    PWCOMPLEXLIST=$PWCOMPLEXLIST"${CHKVALUE[$INDEX]} IS NOT SET\n"
    elif [[ $OUTPUT -eq "0" ]]
    then
      if [[ $REMARKCHK = '#' ]]
      then
        PWCOMPLEXRLT="PASSWORD COMPLEXITY : DETECTED\n"
        PWCOMPLEXLIST=$PWCOMPLEXLIST"${CHKVALUE[$INDEX]} IS NOT SET\n"
      elif [[ $REMARKCHK != "#" ]]
      then
        PWCOMPLEXLIST=$PWCOMPLEXLIST"${CHKVALUE[$INDEX]} IS SET\n"
      fi
    fi
  let "INDEX = $INDEX + 1"

  done
echo "----------------------------------------------------------------------------------------------------------" >> $CHECKRESULT
echo "# U-02 PASSWORD COMPLEXITY" >> $CHECKRESULT
printf "$PWCOMPLEXRLT" >> $CHECKRESULT
printf "$PWCOMPLEXLIST" >> $CHECKRESULT
printf "\n" >> $CHECKRESULT
fi


############################################################ U-46~48 ############################################################
PWPOLICYRLT=
PWPOLICYLIST=
#"^" 정규 표현식으로 ^ 뒤의 문자가 가장 첫 문자임을 나타낸다
CHKVALUE=( "^PASS_MIN_LEN\{0,\}\s\{0,\}[5|9}]" "^PASS_MAX_DAYS\{0,\}\s\{0,\}90" "^PASS_MIN_DAYS\{0,\}\s\{0,\}1")
recordvalue=("PASS_MIN_LEN" "PASS_MAX_DAYS" "PASS_MIN_DAY")

ELEMENT_COUNT=${#CHKVALUE[@]}
INDEX=0

while [ "$INDEX" -lt "$ELEMENT_COUNT" ]
do
OUTPUT=
ex targetconfig/login.defs_test +/"${CHKVALUE[$INDEX]}"/ -s +'p|q!' 1 > /dev/null
OUTPUT=$?
REMARKCHK=$(ex targetconfig/login.defs_test +/"${CHKVALUE[$INDEX]}"/ -s +'p|q!' | awk '{ print $1 }')
    if [ $OUTPUT -eq "1" ]
    then
    PWPOLICYRLT="PASSWORD POLICY : DETECTED\n"
    PWPOLICYLIST=$PWPOLICYLIST"${recordvalue[$INDEX]} IS NOT SET\n"

    elif [[ $OUTPUT -eq "0" ]]
    then
        if [[ $REMARKCHK = "#" ]]
        then
            PWPOLICYRLT="PASSWORD POLICY : DETECTED\n"
            PWPOLICYLIST=$PWPOLICYLIST"${recordvalue[$INDEX]} IS NOT SET\n"
        elif [[ $REMARKCHK != "#" ]]
        then
            PWPOLICYRLT="PASSWORD POLICY : UNTECTED\n"
            PWPOLICYLIST=$PWPOLICYLIST"${recordvalue[$INDEX]} IS SET\n"
        fi
    fi
let "INDEX = $INDEX + 1"
done

echo "# U-46/47/48 PASSWORD POLICY" >> $CHECKRESULT
printf "$PWPOLICYRLT" >> $CHECKRESULT
printf "$PWPOLICYLIST" >> $CHECKRESULT
printf "\n" >> $CHECKRESULT
echo "# U-03 ACCOUNT LOCK POLICY" >> $CHECKRESULT
ACCLOCKRLT=
ACCLOCKLIST=
CHKVALUE=("pam_tally2.so" "deny=5" "unlock_time=60" "no_magic_root" "reset")

ELEMENT_COUNT=${#CHKVALUE[@]}
INDEX=0
while [ "$INDEX" -lt "$ELEMENT_COUNT" ]
do
OUTPUT=
ex targetconfig/system-auth +/"${CHKVALUE[$INDEX]}"/ -s +'p|q!'
OUTPUT=$?
  if [ $OUTPUT -eq "1" ]
  then
  ACCLOCKRLT="ACCOUNT LOCK POLICY : DETECTED\n"
  ACCLOCKLIST=$ACCLOCKLIST"${CHKVALUE[$INDEX]} IS NOT SET\n"
  elif [ $OUTPUT -eq "0" ]
  then
  ACCLOCKRLT="ACCOUNT LOCK POLICY : UNDETECTED\n"
  ACCLOCKLIST=$ACCLOCKLIST"${CHKVALUE[$INDEX]} IS SET\n"
  fi
let "INDEX = $INDEX + 1"
done
printf "$ACCLOCKRLT" >> $CHECKRESULT
printf "$ACCLOCKLIST" >> $CHECKRESULT
printf "\n" >> $CHECKRESULT

############################################################ U04 ############################################################
echo "# U-04 PASSWD FILE CONFIG" >> $CHECKRESULT
ROOTSHADOW=targetconfig/shadow_test
if [ -f "$ROOTSHADOW" ]
then
  echo "SHADOW FILE : UNDECTECTED" >> $CHECKRESULT
else
  echo "SHADOW FILE : DECTECTED" >> $CHECKRESULT
fi
#FILE=/etc/passwd
FILE=targetconfig/passwd_test
PASSENCRLT="USER PASSWORD ENCRYPT : UNDECTECTED\n"
PASSENCLIST=
while read word
do
USERFIELD=$(echo $word | awk -F: '{ print $1 }')
SECONDFIELD=$(echo $word | awk -F: '{ print $2 }')
    if [[ $SECONDFIELD != "x" ]]
    then
        PASSENCRLT="USER PASSWORD ENCRYPT : DECTECTED\n"
        PASSENCLIST=$PASSENCLIST"USER \" $USERFIELD \" PASSWORD IS NOT ENCRYPT(SECONDFILE :$SECONDFIELD)\n"
    fi
done <"$FILE"
printf "$PASSENCRLT" >> $CHECKRESULT
printf "$PASSENCLIST" >> $CHECKRESULT
printf "\n" >> $CHECKRESULT

############################################################ U-16 ############################################################
#ROOTPROFILE=/root/.profile
#ETCPROFILE=/etc/profile
ROOTPROFILE=targetconfig/.profile
ETCPROFILE=targetconfig/profile
echo "#U-16 PROFILE ENVIRONMENT" >> $CHECKRESULT
if [ -f $ROOTPROFILE ]
then
  # sed 명령으로 파일의 내용을 찾는다 -n 옵션은 찾은 내용이 유효할 때문 출력한다.(silent mode)
  CHKROOTPROFILE=$(sed -n '/\.:/p' $rootprofile)
  if [[ -n $CHKROOTPROFILE ]]
  then
    echo "ROOT PROFILE : VULNERABILITY" >> $CHECKRESULT
  fi
else
  echo "ROOT PROFILE : NOT EXITS" >> $CHECKRESULT
fi
if [ -f $ETCPROFILE ]
then
  echo "GLOBAL PROFILE IS EXITS" >> $CHECKRESULT
  CHKROOTPROFILE=$(sed -n '/\.:/p' $ETCPROFILE)

  if [[ -z $CHKROOTPROFILE ]]
  then
    echo "GLOBAL PROFILE VULNERABILITY : UNDECTECTED" >> $CHECKRESULT
  elif [[ -n $CHKROOTPROFILE ]]
  then
      echo "GLOBAL PROFILE VULNERABILITY : DECTECTED" >> $CHECKRESULT
  fi
else
  echo "GLOBAL PROFILE : NOT EXITS"
fi
printf "\n" >> $CHECKRESULT

############################################################ U18,19 ############################################################

echo "#U-18/19 USER FILE PERMISSION" >> $CHECKRESULT
# stat 명령을으로 파일의 상태 값 체크 각 옵션은 --help로 확인 가능하다.
passwdchkval=($(stat -c "%a %U %n" ~/targetconfig/passwd_test))
shadowchkval=($(stat -c "%a %U %n" ~/targetconfig/shadow_test))
if [[ ${passwdchkval[0]} -gt "644" || ${passwdchkval[1]} != "root" ]]
then
  echo ${passwdchkval[2]} "IS LEAK" >> $CHECKRESULT
fi
if [[ ${shadowchkval[0]} -gt "400" || ${shadowchkval[1]} != "root" ]]
then
  echo ${shadowchkval[2]} "IS LEAK" >> $CHECKRESULT
fi
printf "\n" >> $CHECKRESULT

############################################################ U24 ############################################################

echo "#U-24 SID, SGID, STICKY BIT" >> $CHECKRESULT
cd targetconfig/sidchktarget/
stat -c "%a %U %n" * | while read line
do
  # expr 명령으로 서브 쉘의 결과 길이를 구한다.
  PERMISSIONLENGTH=$(expr length $(echo $line | awk '{ print $1 }'))
  CHKFILE=$(echo $line | awk '{ print $3 }')
    if [[ $PERMISSIONLENGTH -ge "4" ]]
    then
      sid=$(expr substr $PERMISSIONLENGTH 1 1)
      echo $CHKFILE " FILE IS LEAK" >> ~/$CHECKRESULT
    fi
done
printf "\n" >> ~/$CHECKRESULT

############################################################ U17 ############################################################
cd
echo "#U-17 NO OWNER" >> $CHECKRESULT
#find 명령의 -nouser 옵션으로 소유자가 없는 파일을 찾는다
find /root/targetconfig/ -nouser -not -path "/root/targetconfig/nousertarget/opt/*" -not -path "/root/targetconfig/nousertarget/var/lib/docker/*" 2>/dev/null | while read line
do
  echo $line "FILE HAS NO OWNER" >> $CHECKRESULT
done
printf "\n" >> $CHECKRESULT
