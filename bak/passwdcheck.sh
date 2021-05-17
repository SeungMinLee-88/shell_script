#!/bin/bash -x
export NCURSES_NO_UTF8_ACS=1
##!/bin/bash -x or set -v want area set +v or set -o verbose want area set +o verbose
#while read word && [[ $word != end ]]
#do if look "$word" > /dev/null
#then echo "\"$word\" 는 유효함."
#else echo "\"$word\" 는 유효하지 않음."
#fi
#done <"$file"
trap 'rm -f $TEMPFILE; exit $USER_INTERRUPT' 0 1 2 24
#echo "모든 사용자 목록:"
#OIFS=$IFS; IFS=: # /etc/passwd 는 필드 구분자로 ":"를 씁니다.
#while read name passwd uid gid fullname ignore
#do
#echo "$name ($fullname)"
#done </etc/passwd # I/O 재지향.
#IFS=$OIFS # 원래 $IFS 를 복구시킴.
# 이 코드도 Heiner Steven 이 제공해 주었습니다.
TEMPFILE="temppasswd"
uservalues=
user=

cd ~/john-1.9.0/run

checkinstall=$?
echo "checkinstall : " $checkinstall
case $checkinstall in
0)
echo "continue"
export PATH=/root/john-1.9.0/run/:$PATH
unshadow /etc/passwd /etc/shadow > hashpasswd
john --show hashpasswd > checkpasswd
file=checkpasswd
checkresult=checkresult.txt
echo "" > $checkresult
checkedcnt=0
while read word && [[ $word != "7 password hashes cracked, 0 left" &&  $word != "" ]]
do
#echo "word : $word"

passwordstr=$(echo $word | awk -F: '{ print $2 }')
passwordlength=$(expr length $passwordstr)
alphalength=$(echo "$passwordstr" | grep -o "[a-zA-Z]" | wc -l)
numericlength=$(echo "$passwordstr" | grep -o "[0-9]" | wc -l)
speciallength=$(echo "$passwordstr" | grep -o "[!~@#$%^&*()?+=\/\\|]" | wc -l)
echo " passwordstr:  "$passwordstr " passwordlength:  "$passwordlength " alphalength:  "$alphalength" numericlength: "$numericlength" speciallength: "speciallength
  if [[ $passwordlength -lt 15 || $alphalength -lt 1 || numericlength -lt 1 || speciallength -lt 1 ]]
  then
    (( checkedcnt++ ))
    putval=$(echo $word | awk -F: '{ print $1 }')
    echo "user " $putval " password is leak!!" >> $checkresult
  fi

passwordstr=
passwordlength=
alphalength=
numericlength=
speciallength=
done <"$file"
echo "$checkedcnt user password leak please fix" >> $checkresult

sleep 100
;;
1)
echo "john the ripper not installed"
wget https://www.openwall.com/john/k/john-1.9.0.tar.gz
;;
esac




sleep 10
function checkvul()
{
setconfig=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice config menu" 20 51 4 \
        "set user" "" ON \
                "EXIT"  "EXIT" off)
echo $setconfig
sleep 1
}

while true # 무한 루프.
do
checkvul
okorcancel=$?
sleep 1
  case $okorcancel in
  1)
    echo "you choice cancel! goobye!"
    exit 0
    ;;
  0)
    echo "continue"
            dialog --title --stdout "My first dialog" --clear \
                    --yesno "Do you want check vulnerability" 10 30
            case $? in
              0)
                echo "continue"
                ;;
              1)
                echo "cancel"
                break
                ;;
            esac

        cd ~/john-1.9.0/run

        sleep 1
          if [[ $? -eq "1" ]]
          then
            echo "john the ripper not installed"
            sleep 2
            break
          else
            export PATH=/root/john-1.9.0/run/:$PATH
            unshadow /etc/passwd /etc/shadow > hashpasswd
            john --show hashpasswd > checkpasswd
                        echo $?
              if [[ "$?" -eq $SUCCESS ]]
              then
                cat checkpasswd
                file=checkpasswd
                while read word && [[ $word != end ]]
                do
                  echo "$word"
                done <"$file"
                sleep 1
              else
                echo "fault"
                sleep 1
              fi
          fi

  ;;
  esac
done

    sleep 10