#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
##!/bin/bash +x
# for debuging option it's show every run command
trap 'rm -f $TEMPFILE; exit $USER_INTERRUPT' 0 1 2 24
#trap "echo \"find interrupt\" ; exit 0" 0 1 2 24
#exec 0<&6 6<&-
#password="123qwe"
#exec 6<&0
#exec < ${password}
#read password1
# 6번 파일 디스크립터에 저장되어 있던 표준입력을 복구시키고,
# 다른 프로세스가 쓸 수 있도록 6번 파일 디스크립터를 프리( 6<&- )시킴.
#exec 0<&6 6<&-\
#sleep 100
#rm -rf /home/test
#passwd test --stdin < $TEMPFILE
#passwd test --stdin
#echo "123qwe" > temppasswd
#userdel test
#yes | rm -i /home/test
#useradd test
#echo "123qwe" | passwd test --stdin
#$(echo test 3>&1 1>&2 2>&3)
#function setuser(){
#uservalues=$(dialog --stdout --title "Make User" --clear \
#--form "\nPlease Input Username and User password" 25 60 16 \
#"Username:" 1 1 "" 1 15 30 30 \
#"Password:" 2 1 "" 2 15 30 30  3>&1 1>&2 2>&3)}

#index=0
#while [ "$index" -lt "$element_count" ]
#do # 배열의 모든 요소를 나열해 줍니다.
# echo ${colors[$index]}
# let "index = $index + 1"
#done
# 각 배열 요소는 한 줄에 하나씩 찍히는데,
# 이게 싫다면 echo -n "${colors[$index]} " 라고 하면 됩니다.
#
# 대신 "for" 루트를 쓰면:
# for i in "${colors[@]}"
# do
# echo "$i"
# done
# (Thanks, S.C.)
#for n in 0 1 2 3 4 5
#do
# echo "BASH_VERSINFO[$n] = ${BASH_VERSINFO[$n]}"
#done
#for sidval in $(stat -c "%a %U %n" targetconfig/sidchktarget/*)
#do
# echo $sidval
#done
#if [ -f ~/.netscape/cookies ] # 있다면 지우고,
#then
# rm -f ~/.netscape/cookies
#fi
#-z
#문자열이 "null"임. 즉, 길이가 0
#3-n
#3문자열이 "null"이 아님.
#stat -c "%a %n" /etc/passwd | awk '{ print $1 }'
#echo "모든 사용자 목록:"
#OIFS=$IFS; IFS=: # /etc/passwd 는 필드 구분자로 ":"를 씁니다.
#while read name passwd uid gid fullname ignore
#do
# echo "$name $passwd $uid $gid $fullname $ignore"
#done </etc/passwd

#while read line
# do
# stat -c "%a %U %n" * $line
# echo $line
# done
# find / -nouser -not -path "/opt/*" -not -path "/var/lib/docker/*" -not -name "testest*" 2>/dev/null
#while read input </dev/tty
#do
#  echo "input :"$input
#  done
#while read input </dev/tty2
#do
#echo "input :"$input
#done
#{ cat notify-finished | while read line; do
#    read -u 3 input
#    echo "$input"
#
# done; } 3<&0
#while read file and out example
#count=0;
#route -n | while read des what mask iface; do
# echo $des
#done
#exit 0
#or below command
#while read des what mask iface; do
# echo $des $what $mask $iface
#done < <(route -n)
# test.cgf content
#nomeTarefa dirOrigem dirDest tipoBkp agendarBkp compactarBkp gerarLog
#1               2       3       4       5               6       7
#a               b       c       d       e               f       g
#h               h       i       j       k               l       n
#while read nomeTarefa dirOrigem dirDest tipoBkp agendarBkp compactarBkp gerarLog
#do
#  echo "nomeTarefa : "$nomeTarefa "dirOrigem : "$dirOrigem
#  count=$((count + 1));#INICIA O COUNT PARA INCREMENTAR O OPTIONS
#  options[$count]=$count") \"$nomeTarefa\"" #CONCATENA O OPTIONS
#done < "test.cgf"
#IFS=" "
#cat whilefile.txt | while  read line
#do
#  echo "line : "$line
#  count=$((count + 1));#INICIA O COUNT PARA INCREMENTAR O OPTIONS
#  options[$count]=$count") \"$nomeTarefa\"" #CONCATENA O OPTIONS
#done

#$ var1=Hello
#$ SPACE='  '
#$ VAR2=Wissam
#$ VAR="$var1${SPACE}$VAR2"
#$ echo "${VAR}"
#Hello  Wissam

#매개변수가 세트되지 않았다면 default를 사용합니다.
#echo ${username-`whoami`}
# $username이 여전히 세트되어 있지 않다면 `whoami`의 결과를 에코.
#참고: 이렇게 하면 ${parameter:-default}라고 하는 것과 거의 비슷하지만 :이 있을 때는 매개변
#수가 선언만 되어 값이 널일 경우에도 기본값을 적용시킵니다.


output_args_one_per_line()
{
 for arg
 do echo "[$arg]"
 done
}
echo; echo "IFS=\" \""
echo "-------"
IFS=" "
var=" a   b      c  "
output_args_one_per_line $var


echo; echo "IFS=:"
echo "-----"
IFS=:
var=":a::b:c:::" # 위와 같지만 ":" 를 " "로 바꿔줍니다.
output_args_one_per_line $var

#!/bin/bash
#username0=
# username0 는 선언만 되고 널로 세트됐습니다.
#echo "username0 = ${username0-`whoami`}"
# 에코 되지 않습니다.
#--squeeze-repeats(나 -s) 옵션은 연속적인 문자들 중에서 첫번째만 남기고 나머지 문자들은 지워 줍니다.
#이 옵션은 과도한 공백 문자를 지울 때 유용합니다.
max2 () # 두 숫자중 큰 수를 리턴.
{ # 주의: 비교할 숫자는 257보다 작아야 합니다.
if [ -z "$2" ]
then
 return $E_PARAM_ERR
fi
if [ "$1" -eq "$2" ]
then
 return $EQUAL
else
 if [ "$1" -gt "$2" ]
 then
 return $1
 else
 return $2
 fi
fi
}
max2 33 34
return_val=$?


#\(\([1-2]\{0,1\}\)\([0-9]\{1,1\}\)\([0-9]\{1,1\}\)\.\)
#1 to2 가 0번이상 1번이하 0-9가 1번이상 1번이하 2번 반복 마지막 .으로 끝나는거
#\(\([1-2]\{0,1\}\)\([0-9]\{0,1\}\)\([0-9]\{1,1\}\)\)\{1,3\}\.
#echo "030" | grep -o "\([1-2]\)\{0,1\}\([1-9]\|0\)\{1,2\}" | wc -l
#/^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$/
#echo "2a" | grep -o "^\([1-2]\{0,1\}\)" | wc -l


sleep 10
echo "디렉토리를 바꾸겠습니다."
cd /usr/local
echo "지금은 `pwd` 에 있습니다."
echo "집(home)으로 돌아갑니다."
cd
echo "지금은 `pwd` 에 있습니다."
echo


file=targetconfig/sidchk
while read word
do
  echo $word | awk -F/ '{ print $4 }'
  #ls -l $word
done <"$file"

sleep 10
permission=$(ls -l /etc/passwd | awk '{ print $2 }')
echo $permission
#echo "${permission:2:1}"
expr substr $permission 4 1

sleep 10
output_args_one_per_line()
{
 for arg
 do echo "[$arg]"
 done
}
IFS=:
var="/root/john-1.9.0/run/::/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/opt/java1.8/bin:/home/laravel/.config/composer/vendor/bin:/root/bin" #

output_args_one_per_line $var

sleep 10
#!/bin/bash
# 매개변수 치환 연산자인 # ## % %% 를 써서 패턴 매칭하기.
var1=abcd12345abc6789
pattern1=a*c # * (와일드 카드)는 a 와 c 사이의 모든 문자와 일치합니다.
echo
echo "var1 = $var1" # abcd12345abc6789
echo "var1 = ${var1}" # abcd12345abc6789 (다른 형태)
echo "${var1} 에 들어 있는 글자수 = ${#var1}"
echo "pattern1 = $pattern1" # a*c ('a'와 'c' 사이의 모든 문자)
echo
echo '${var1#$pattern1} =' "${var1#$pattern1}" # d12345abc6789
# 앞에서부터 가장 짧게 일치하는 3 글자를 삭제 abcd12345abc6789
# ^^^^^^^^^^ |-|
echo '${var1##$pattern1} =' "${var1##$pattern1}" # 6789
# 앞에서부터 가장 길게 일치하는 12 글자를 삭제 abcd12345abc6789
# ^^^^^

TEMPFILE="temppasswd"
uservalues=
user=
function setuser()
{
uservalues=($(dialog --title "Make User" --clear \
--form "\nPlease Input Username and User password" 25 60 16 \
"Username:" 1 1 "" 1 15 30 30 \
"Password:" 2 1 "" 2 15 30 30 3>&1 1>&2 2>&3))
#() is not mean sub shell it locate array value ex) Array=(element1 element2 element3) /{xxx,yyy,zzz,...}
}

while true # 무한 루프.
do
setuser
okorcancel=$?
echo ${#uservalues[*]}
echo ${uservalues[0]}
echo "111111111111111111111"
echo ${uservalues[1]}
echo "?????" $okorcancel
sleep 1
  case $okorcancel in
  1)
    echo "you choice cancel! goobye!"
    exit 0
    ;;
  0)
    echo "continue"
        if [ ${#uservalues[*]} -eq "0" ] || [[ ${uservalues[0]} = "" ]] || [[ ${uservalues[1]} = "" ]]
        then
          echo "fault"
          sleep 1
            dialog --title --stdout "My first dialog" --clear \
                    --yesno "Hello, this is my first dialog program" 10 30
            case $? in
              0)
                echo "cancel"
                ;;
              1)
                echo "continue"
                break
                ;;
            esac
        else
        userexist=$(sed -n "/${uservalues[0]}/p" /etc/passwd | awk -F: '{ print $1 }')
        echo "userexist :" $userexist
        sleep 1
          if [[ ${userexist} != "" ]]
          then
            echo "${uservalues[0]} aleady exits user!!!"
            sleep 2
            continue
          else
            useradd ${uservalues[0]}
            echo $?
              if [ "$?" -eq $SUCCESS ]
              then
                echo "adding user fail please check script ex) #!/bin/bash -x"
                sleep 1
              else
                echo ${uservalues[1]} | passwd test --stdin
                sleep 1

              fi
          fi
        fi
  ;;
  esac
    done

    sleep 10