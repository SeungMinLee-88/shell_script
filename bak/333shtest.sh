#!/bin/bash
export NCURSES_NO_UTF8_ACS=1

####################################### delete config test #######################################
temprulefile=richrules.txt
selectedzone=deltestconf
echo "defalut IFS : "$IFS
ORIFS=$IFS
while true
do
#selectedzone=$2
    services=($(firewall-cmd --permanent --list-services --zone=$selectedzone 2>/dev/null))
    ports=($(firewall-cmd --permanent --list-ports --zone=$selectedzone 2>/dev/null))
    firewall-cmd --permanent --list-rich-rules --zone=$selectedzone >> $temprulefile
    echo " cat : " $(cat $temprulefile)
    echo " services len:"${#services[0]}
    echo " ports len:"${#ports[0]}
    echo " temprulefile len:" $(expr length "$(cat richrules.txt)")
    serviceslen=${#services[0]}
    portslen=${#ports[0]}
    richrules=$(expr length "$(cat richrules.txt)")

    if [[ $serviceslen -eq 0 && $portslen -eq 0 && $portslen -eq 0 ]]
    then

      dialog --title --stdout "dialog" --clear --msgbox "nothing are settings set." 10 30
    continue
    fi
    if [ -n "$temprulefile" ] # 이번엔 $string1 을 쿼우트 시켜서 해보죠.
    then
     echo "temprulefile is not null"
    else
     echo "temprulefile is not"
    fi
    exit 0
    arrnum=2

    #selectarrays="${services[0]}|service\n ${services[0]}\n on\n"
    #printf "$selectarrays"
#    exit 0
    #unset services[0]

      IFS=$'\n'
#      sleep 10

      deleteconfig=$(dialog --clear --stdout --title "choice service or port" \
      --radiolist "(selectd zone:$selectedzone)" 20 60 4 \
$(for arg in ${services[@]}
      do
      echo "$arg|service"
      echo " "
      echo "off"
      (( arrnum++ ))
            done) \
            $(for arg in ${ports[@]}
            do
      echo "$arg|port"
      echo " "
      echo "off"
      (( arrnum++ ))
            done) \
            $(for arg in $(cat $temprulefile)
            do
      echo "$arg|rich-rule"
      echo " "
      echo "off"
      (( arrnum++ ))
      done))
      retval=$?
      echo "retval : "$retval
      IFS=$ORIFS
      echo "defalut IFS : "$IFS
      echo "deleteconfig : "$deleteconfig

        if [[ $retval -eq 0 && -n "$deleteconfig" ]] ## $xyz 가 널인지 테스트
        then
          echo "not null"
          funcrlt="succes"
          break
        elif [[ $retval -eq 0 && -z "$deleteconfig" ]]
        then
          dialog --title --stdout "dialog" --clear --msgbox "please select service" 10 30
          continue
        elif [[ $retval -ne 0 ]]
        then
          echo "cancel selected"
          funcrlt="cancel"
        fi
            if [[ $funcrlt == "cancel" ]]
            then
            echo "funcrlt is selected"
            dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
            sleep 1
            continue
            elif [[ $funcrlt != "cancel" ]]
            then
            echo "deleteconfig :" $deleteconfig
            configval=$(echo "$deleteconfig" | awk 'BEGIN { FS="|" } { print $1 }')
            configtype=$(echo "$deleteconfig" | awk 'BEGIN { FS="|" } { print $2 }')
            echo "sh setfirewall.sh " "deleteconfig" "$selectedzone"  "$configtype" "$configval"
              getresult=$(sh setfirewall.sh "deleteconfig" "$selectedzone"  "$configtype" "$configval")
              echo "getresult :"$getresult
                if [[ $getresult != "success" ]]
                then
                  dialog --title --stdout "error cause" --clear --msgbox "\"$getresult\" error is caused!" 10 30
                else
                  dialog --title --stdout "My first dialog" --clear --msgbox "delete service success!" 10 30
                break
                fi
            continue
            sleep 10
            getresult=$(sh setfirewall.sh "$setconfig" "$zonename")
            echo "getresult :"$getresult
            echo "config success"
            dialog --title --stdout "My first dialog" --clear --msgbox "cofig delete success" 10 30
            continue
            fi
done
exit 0

####################################### delete config test end #######################################
####################################### delete zone test #######################################

while true
do
  menuzone=
  deletezone=
  zonelist=($(firewall-cmd --permanent --get-zones | awk -f zonelist.awk))
    for arg in ${zonelist[@]}
    do
    echo "var : "$arg
    menuzone="$menuzone $arg $arg off"
    done
    echo "menuzone : " "$menuzone"

      deletezone=$(dialog --stdout --clear --title "select zone or makezone" \
      --radiolist "zone list" 20 60 4  \
      $menuzone)
      retval=$?
      echo "retval : "$retval
        if [[ $retval -eq 0 && -n "$deletezone" ]] ## $xyz 가 널인지 테스트
        then
        echo "not null"
        funcrlt="succes"
        #continue
        elif [[ $retval -eq 0 && -z "$deletezone" ]]
        then
        dialog --title --stdout "dialog" --clear --msgbox "please select zone" 10 30
        continue
        elif [[ $retval -ne 0 ]]
        then
        echo "function cancel selected"
        funcrlt="cancel"
        fi

          if [[ $funcrlt == "cancel" ]]
          then
          echo "cancel selected"
          dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
          sleep 1
          continue
          elif [[ $funcrlt != "cancel" ]]
          then
          echo "deletezone :" $deletezone
          echo "sh setfirewall.sh " "$setconfig" "$deletezone"
          exit 0
          getresult=$(sh setfirewall.sh "deleteconfig" "$selectedzone"  "$configtype" "$configval")
          echo "getresult :"$getresult
            if [[ $getresult != "success" ]]
            then
            dialog --title --stdout "error cause" --clear --msgbox "\"$getresult\" error is caused!" 10 30
            else
            dialog --title --stdout "My first dialog" --clear --msgbox "delete service success!" 10 30
            continue
            fi
          continue
          sleep 10
          getresult=$(sh setfirewall.sh "$setconfig" "$zonename")
          echo "getresult :"$getresult
          echo "config success"
          dialog --title --stdout "My first dialog" --clear --msgbox "cofig delete success" 10 30
          continue
          fi
done
exit 0

####################################### delete zone test END#######################################


#trap 'rm -f "$temprulefile" ; exit 0' 0 1 2 24
              funcrlt="cancel"
               echo "funcrlt : "$funcrlt
                if [[ $funcrlt = "cancel" ]]
                then
                  echo "cancel selected"
                  dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
                  sleep 1
                  continue
                elif [[ $funcrlt != "cancel" ]]
                then
                  echo "config success"
                  dialog --title --stdout "My first dialog" --clear --msgbox "cofig delete success" 10 30
                  continue
                fi
                sleep 10


services=($(firewall-cmd --permanent --list-services --zone=deltest 2>/dev/null))
    ports=($(firewall-cmd --permanent --list-ports --zone=deltest 2>/dev/null))
    firewall-cmd --permanent --list-rich-rules --zone=deltest > $temprulefile
    cat $temprulefile
    echo " services :"$services
    arrnum=2

    selectarrays="${services[0]} ${services[0]} on"
    unset services[0]

      IFS=$'\n'
#      sleep 10

      selectconfig=$(dialog --clear --stdout --title "select config" \
      --radiolist "config list" 20 60 4 \
      $(for arg in ${services[@]}
      do
      echo "$arg|services"
      echo " "
      echo "off"
      (( arrnum++ ))
            done) \
            $(for arg in ${ports[@]}
            do
      echo "$arg|ports"
      echo " "
      echo "off"
      (( arrnum++ ))
            done) \
            $(for arg in $(cat $temprulefile)
            do
      echo "$arg|richrules"
      echo " "
      echo "off"
      (( arrnum++ ))
      done))
IFS=$ORIFS


echo "selectconfig : "$selectconfig
sleep 10


$(for arg in $(cat richrules.txt)
do
echo $arrnum "\"$arg\"" "off"
(( arrnum++ ))
done)

IFS=$ORIFS
sleep 10

      IFS=$'\n'
      for arg in $(cat richrules.txt)
      do
      #echo "var : "$arg
      selectarrays="$selectarrays $arrnum '$arg' off"
      (( arrnum++ ))
      done
      IFS=$OIFS
      echo "IFS : "$IFS
      echo "selectarrays : " $selectarrays
      sleep 10

#ports="443/tcp 3389/tcp 33/tcp 12/tcp 31/tcp 23/tcp"
#IFS=" "
#set IFS newline
#ORIFS=$IFS;
#IFS="
#" # OR can set below line command
#IFS=$'\n'
#IFS=$OIFS #RESET IFS
# check str length
#echo ${#stringZ} # 15
#echo `expr length $stringZ` # 15
#echo `expr "$stringZ" : '.*'` # 15
#"\(^[^0]\{1,1\}[0-9][^a-z]\{0,4\}\)"
# above regular express is mean word is started number except zero(0) and word not contain alphabet and is ...
#echo "0" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}$\)" | wc -l
# echo "1111" | grep -o "\(^[0-9]\{1,4\}$\)" | wc -l
#for arg in "$*"
#do
# echo "Arg #$index =" "$arg"
# let "index+=1"
#done # $* 는 모든 인자를 하나의 낱말로 봅니다.
#echo
#exit 0
echo; echo "IFS=:"
echo "-----"
IFS=:
#var=":a::b:c:::" # 위와 같지만 ":" 를 " "로 바꿔줍니다.
#echo "var : "$var
echo $(cat /etc/passwd)
