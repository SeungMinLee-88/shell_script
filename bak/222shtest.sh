#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
#a=letter_of_alphabet
#letter_of_alphabet=z
#echo "a = $a" # 직접 참조.
#echo "Now a = ${!a}" # 간접 참조.
#${!varprefix*}, ${!varprefix@}
#이미 선언된 변수들 중에 varprefix로 시작하는 변수들.
#xyz23=whatever
#xyz24=
#a=${!xyz*} # 선언된 변수중 "xyz"로 시작하는 변수로 확장.
##echo "a = $a" # a = xyz23 xyz24
#a=${!xyz@} # 위와 같음.
#echo "a = $a" # a = xyz23 xyz24
# 표준 문법.
#for a in 1 2 3 4 5 6 7 8 9 10
#do
# echo -n "$a "
#done
#echo; echo
# +==========================================+
# 이제는 C 형태의 문법을 써서 똑같은 일을 해 보겠습니다.
#LIMIT=10
#for ((a=1; a <= LIMIT ; a++)) # 이중 소괄호와 "$" 없는 "LIMIT".
#do
# echo -n "$a "
#done # 'ksh93' 에서 빌려온 문법.
#echo; echo

#for ((a=1, b=1; a <= LIMIT ; a++, b++)) # 콤마를 쓰면 여러 연산을 함께 할 수 있습니다.
#do
# echo -n "$a-$b "
#done
#echo; echo
#exit 0
#sleep 10
#num=1
# for arg in 1 2 3 4 5
# do echo "[$arg]"
# (( num++ ))
# echo "num : "$num
# done
# sleep 10

#selectconfig=$(dialog --clear --title 'select config' --radiolist 'config list' 20 60 4 http ' ' off nfs ' ' off 23/tcp ' ' off 443/tcp ' ' off 1521/tcp ' ' off 33/tcp ' ' off 'rule family="ipv4" source address="192.168.56.1" port port="30-40" protocol="tcp" accept' ' ' off 'rule family="ipv4" port port="40-50" protocol="tcp" accept' ' ' off 3>&2 2>&1 1>&3)
#echo "selectconfig : "$selectconfig
#sleep 10
#tempfile=portset
#trap 'rm -f "$tempfile"' 0 1 2 24

dialog  --stdout --title "My input box" --clear \
--form "\nDialog Sample Label and Values" 25 60 16 \
"start port:" 1 1 "555" 1 25 10 4 \
"end port" 3 1 "666" 3 25 10 4 \
"source address:" 5 1 "11.23.145.32" 5 18 18 15  > $tempfile

cat "portset : "$tempfile

while read arg
do
echo "arg : " $arg
richconfigs[$num]=$arg
(( num++ ))
done < $tempfile

echo "richconfigsarr[*] : "${#richconfigs[*]}
echo "richconfigsarr[0] : "${richconfigs[0]}
echo "richconfigsarr[1] : "${richconfigs[1]}
echo "richconfigsarr[2] : "${richconfigs[2]}

sleep 10


#!/bin/bash
set -f
echo $0

i=1
for var in $@
do
    echo "$i => $var"
    ((i++))
done
exit 0

selrlt=
conftype=
confport=
confsourceadr=
confportrange=
#echo 0-33 | grep -o "\(^[0-9]\{2,5\}\|[1-9]\{1,1\}\)\(\-\)\([0-9]\{1,5\}\)" | wc -l
output_args_one_per_line()
{
  set -a string=aaaaa
  richconfigs=
num=0
echo "arg : "$arg
for arg
do echo "$arg"
richconfigs[num]="$arg"
(( num++ ))
done
}
set -b
exec 3>&2          # 3 is now a copy of 2
exec 2> /dev/null  # 2 now points to /dev/null
#exMYVAR=1729
export MYVAR=1729
echo "MYVAR : "$MYVAR
echo "!!!!!!!!!!!! : "$! # current background procedd $$ : pid at myself
echo "string : "$string
#exit 0
sleep 10
exit 0
exec 2>&3          # restore stderr to saved
exec 3>&-          # close saved version

 declare -a test=("$returnvar")
echo "test[*] : "${#test[*]}
echo "returnvar : " $returnvar
whitespace="$returnvar"
echo "whitespace : "$whitespace
num=0
for arg in $(echo "$whitespace")
do
echo "arg :"$arg
richconfigs[num]=$arg
(( num++ ))
done

#IFS=" "
#output_args_one_per_line "$returnvar"
#richconfigsarr=($richconfigs)

function setrichrule()
{
  #echo 1-30 | grep -o "\(^[0-9]\{1,5\}|^[1-9]\-[0-9]\{1,5\}\)" | wc -l
#"source address:" 1 1 "111" 1 18 5 3 \
#"" 1 1 "222" 1 24 5 3 \
#"" 1 1 "333" 1 30 5 3 \
#"" 1 1 "444" 1 36 5 3 \
#"start port:" 3 1 "555" 3 25 10 4 \
#"end port" 5 1 "666" 5 25 10 4
richconfigs=($(dialog  --stdout --title "My input box" --clear \
--form "\nDialog Sample Label and Values" 25 60 16 \
"start port:" 1 1 "555" 1 25 10 4 \
"end port" 3 1 "666" 3 25 10 4 \
"source address:" 5 1 "11.23.145.32" 5 18 18 15 \
))
return $richconfigs
#echo ${#richconfigs[*]}
#echo ${richconfigs[0]}
#echo ${richconfigs[1]}
#echo ${richconfigs[2]}
#echo ${richconfigs[3]}
#echo ${richconfigs[4]}
#echo ${richconfigs[5]}
}
setport=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice service or range" 20 60 4 \
            "rich rule"  "ex)30-40 port range, set source IP" ON \
        "80"  "http" ON \
        "443"  "https" off \
        "8080"  "was" off \
        "22"  "ssh" off \
        "EXIT"  "EXIT" off)

selrlt=$?
echo $setport

echo $selrlt
  case $selrlt in
  1)
    echo "cancel"
  ;;
  0)
    echo "continue"
    dialog --title --stdout "My first dialog" --clear \
            --yesno "is \"$setport\" is your choice configure?" 10 30
      selrlt=$?
      case $selrlt in
      0)
        echo "continue"

          case $setport in
          "rich rule")
              while true
              do
                setrichrule
                  echo ${#richconfigs[*]}
                  echo ${richconfigs[0]}
                  echo ${richconfigs[1]}
                  echo ${richconfigs[2]}
                setrichrulerlt=$?
                echo "setrichrulerlt : "$setrichrulerlt
                  if [[ ${#richconfigs[*]} -eq "3" ]]
                  then
                    srcipchk=$(echo "${richconfigs[2]}" | grep -o "\(^[1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\)" | wc -l)
                    echo "srcipchk : "$srcipchk
                        if [[ srcipchk -ne "1" ]]
                        then
                          echo "source ip not valid!!"
                          sleep 1
                          continue
                        else
                          echo "sh setfirewall.sh $setport ${richconfigs[0]} ${richconfigs[1]} ${richconfigs[2]}"
                          sh setfirewall.sh "$setport" ${richconfigs[0]} ${richconfigs[1]} ${richconfigs[2]}
                          sleep 10
                        fi
                  else
                    sh setfirewall.sh $setport
                  fi
              done
          ;;
          1)

          ;;
          esac
      ;;
      1)
        echo "cancel"

      ;;
      esac
  ;;
  esac