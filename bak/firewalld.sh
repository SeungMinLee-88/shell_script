#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
tempfile=portset
ORIFS=$IFS
trap 'rm -f "$tempfile"' 0 1 2 24
trap "echo \"find interrupt\" ; exit 0" 0 1 2 24

temprulefile=richrules.txt
trap 'rm -f "$temprulefile" ; exit 0' 0 1 2 24


systemctl status firewalld.service 1>/dev/null
chksrv=$?
if [[ $chksrv != "0" ]]
then
echo "firewall service is not running"
exit 0
fi

count=0;
#IFS=" "

#exit
#echo "zonevars : "${zonevar[@]} setconfig=$(
function makezone()
{
zonename=$(dialog --stdout --title "My input box" --clear \
        --inputbox "Please input zone name" \
        16 51 "private"
        )
retval=$?
if [[ $retval -ne "0" ]]
then
zonename="select cancel"
fi
#echo "zonename : "$zonename
#return "$zonename"
#sleep 10

}

portvalues=
function setportrange()
{
case "$1" in
portrange)
portvalues=($(dialog  --stdout --title "My input box" --clear \
--form "\nDialog Sample Label and Values" 25 60 16 \
"range of start port:" 1 1 "" 1 25 10 4 \
"range of end port" 2 1 "" 2 25 10 4 \
))
;;

*)
;;
esac
}

function setrichrule()
{
setrichrulerlt=0
#"source address:" 1 1 "111" 1 18 5 3 \
#"" 1 1 "222" 1 24 5 3 \
#"" 1 1 "333" 1 30 5 3 \
#"" 1 1 "444" 1 36 5 3 \
#"start port:" 3 1 "555" 3 25 10 4 \
#"end port" 5 1 "666" 5 25 10 4
dialog  --stdout --title "My input box" --clear \
--form "\nDialog Sample Label and Values" 25 60 16 \
"start port:" 1 1 "30" 1 25 10 4 \
"end port" 3 1 "40" 3 25 10 4 \
"source address:" 5 1 "192.168.56.1" 5 18 18 15 > $tempfile
retval=$?
if [[ $retval -ne "0" ]]
then
setrichrulerlt="select cancel"
fi
  echo " richconfigs* : "${#richconfigs[*]}

num=0
while read arg
do
echo "arg : " $arg
richconfigs[$num]=$arg
(( num++ ))
done < $tempfile
#return $richconfigs
echo ${#richconfigs[*]}
echo ${richconfigs[0]}
echo ${richconfigs[1]}
echo ${richconfigs[2]}
#echo ${richconfigs[3]}
#echo ${richconfigs[4]}
#echo ${richconfigs[5]}
}
function customport()
{
customportrlt=0
customport=$(dialog --stdout --title "My input box" --clear \
        --inputbox "Please input port value" \
        16 51 "33"
        )
retval=$?
if [[ $retval -ne "0" ]]
then
customportrlt="select cancel"
fi
#echo "zonename : "$zonename
#return "$zonename"
#sleep 10

}
function setfirewalld()
{
  echo "arg1 " $1
selectedzone=$1
while true
do
setport=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice service or range(selectd zone:$selectedzone)" 20 60 4 \
        "remove config"  "remove config" ON \
        "custom port"  "custom port" ON \
        "rich rule"  "ex)30-40 port range, set source IP" ON \
        "http"  "80" off \
        "https"  "443" off \
        "ftp"  "20/21" off \
        "telnet"  "22" off \
        "ssh"  "23" off \
        "EXIT"  "EXIT" off)

setfirewalldrlt=$?
echo $setport

echo $setfirewalldrlt
sleep 1
case $setfirewalldrlt in
  1)
    echo "cancel"
    dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
    break
  ;;
  0)
    echo "continue"
    dialog --title --stdout "My first dialog" --clear \
            --yesno "is \"$setport\" is your choice configure?" 10 30
      firewallchkconfig=$?
      case $firewallchkconfig in
      0)
        echo "continue"

          case $setport in
          "rich rule")
              while true
              do
                setrichrule
                  echo "richconfigs[*] : "${#richconfigs[*]}
                  echo "richconfigs[0] : "${richconfigs[0]}
                  echo "richconfigs[1] : "${richconfigs[1]}
                  echo "richconfigs[2] : "${richconfigs[2]}
                  echo "setconfig : "$setconfig
                  startportchk=$(echo "${richconfigs[0]}" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)
                  endportchk=$(echo "${richconfigs[1]}" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)
                echo "setport : "$setport
                echo "selectedzone : "$selectedzone
                #sleep 1
                  if [[ $setrichrulerlt = "select cancel" ]]
                  then
                    dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
                    break
                  else
                      if [[ ${#richconfigs[*]} -eq "3" ]]
                      then
                        srcipchk=$(echo "${richconfigs[2]}" | grep -o "\(^[1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\.\)\([1-2]\{0,1\}[0-9]\{0,1\}[0-9]\{1,1\}\)" | wc -l)
                        echo "srcipchk : "$srcipchk
                              if [[ ${richconfigs[2]} != "" && srcipchk -ne "1" ]]
                                then
                                  echo "source ip not valid!!"
                                  sleep 1
                                  continue
                              elif [[ ${richconfigs[0]} = "" || ${richconfigs[1]} = "" || startportchk -eq "0" || endportchk -eq "0" ]]
                              then
                                  echo "port value is not valid!!"
                                  sleep 1
                                  continue
                              else
                                  #echo "sh setfirewall.sh "$setport" "${richconfigs[0]}" "${richconfigs[1]}" "${richconfigs[2]}" "$selectedzone""
                                  getresult=$(sh setfirewall.sh "$setport" "${richconfigs[0]}" "${richconfigs[1]}" "${richconfigs[2]}" "$selectedzone")
                                  echo "getresult :"$getresult
                                    if [[ $getresult != "success" ]]
                                    then
                                      dialog --title --stdout "error cause" --clear --msgbox "\"$getresult\" error is caused!" 30 60
                                    else
                                    dialog --title --stdout "My first dialog" --clear --msgbox "firewall configure is success!" 30 60
                                    break
                                    fi
                                  sleep 1
                              fi
                      else
                        sh setfirewall.sh $setport
                      fi
                  fi
              done
          ;;
          "custom port")
            while true
            do
              customport
              if [[ $customportrlt = "select cancel" ]]
              then
                dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
                break
              else
                echo "echo "$customport" | grep -o \"\(^[^0]\{1,1\}[0-9]\{0,4\}\)\" | wc -l"
                #exit 0
                 setportchk=$(echo "$customport" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)

                  if [[ $setportchk -ne "1" ]]
                  then
                    echo "port value is not valid!!"
                    sleep 1
                    continue
                  fi
                    echo "retval : "$retval
                    echo "customport : "$customport
                      if [[ $customport = "" ]]
                      then
                        echo "invalid zonename"
                        sleep 1
                        continue
                      else
                      dialog --title --stdout "My first dialog" --clear \
                            --yesno "is \"$customport\" your input port?" 10 30
                          case $? in
                          0)

                            echo "sh setfirewall.sh" "$setport" "$selectedzone" "$customport"
                            getresult=$(sh setfirewall.sh "$setport" "$selectedzone" "$customport")
                            echo "getresult :"$getresult
                            if [[ $getresult != "success" ]]
                            then
                              dialog --title --stdout "error cause" --clear --msgbox "\"$getresult\" error is caused!" 10 30
                            else
                              dialog --title --stdout "My first dialog" --clear --msgbox "\"$customport\"port is set!" 10 30
                            break
                            fi
                          ;;
                          1)
                          echo "cancel"
                          continue
                          ;;
                          esac
                      fi
              fi
            done
          ;;
        "remove config")

              removezoneorconfig "remove config" $selectedzone
              setportchk=$(echo "$customport" | grep -o "\(^[^0]\{1,1\}[0-9]\{0,4\}\)" | wc -l)
              echo "funcrlt : "$funcrlt
                if [[ $funcrlt == "cancel" ]]
                then
                  echo "cancel selected"
                  dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
                  sleep 1
                  continue
                elif [[ $funcrlt == "nothingset" ]]
                then
                  echo "nothingset "
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
          ;;

          *)
            echo "setport : " $setport
            servicename=$setport
                  echo "sh setfirewall.sh" "serviceset" "$selectedzone" "$servicename"
                  getresult=$(sh setfirewall.sh "serviceset" "$selectedzone" "$servicename")
                  echo "getresult :"$getresult
                  if [[ $getresult != "success" ]]
                  then
                    dialog --title --stdout "error cause" --clear --msgbox "\"$getresult\" error is caused!" 10 30
                  else
                    dialog --title --stdout "My first dialog" --clear --msgbox "\"$servicename\" service is set!" 10 30
                  continue
                  fi
          ;;
          esac
      ;;
      1)
        echo "cancel"
        continue
      ;;
      esac
  ;;
  esac
done
}

function selectzone()
{
zonevar=($(firewall-cmd --permanent --get-zones))
nullval=' '
menuvar="${zonevar[0]} ${zonevar[0]} off"

unset zonevar[0]
for arg in ${zonevar[@]}
do
echo "var : "$arg
menuvar="$menuvar $arg $arg off"
done
echo "$menuvar"
setconfig=$(dialog --stdout --clear --title "select zone or makezone" \
    --radiolist "zone list" 20 60 4  \
    "delete zone" "delete custom zone" on \
    "make zone" "makezone and change default zone" off \
    $menuvar \
    "EXIT"  "EXIT" off)
    retval=$?
echo "retval : "$retval
if [[ $retval -ne "0" ]]
then
  setconfig="cancel"
fi
echo "setconfig : "$setconfig

}


function removezoneorconfig()
{
echo "function removezoneorconfig start"
config="$1"
echo "1var " $config
while true
do
case $config in
  "delete zone")
    menuzone=
    deletezone=
    zonelist=($(firewall-cmd --get-zones | awk -f zonelist.awk))
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
            break
          elif [[ $retval -eq 0 && -z "$deletezone" ]]
          then
            dialog --title --stdout "dialog" --clear --msgbox "please select zone" 10 30
            continue
          elif [[ $retval -ne 0 ]]
          then
            echo "function cancel selected"
            funcrlt="cancel"
          fi
      break
  ;;
  "remove config")

    selectedzone=$2
    services=($(firewall-cmd --permanent --list-services --zone=$selectedzone 2>/dev/null))
    ports=($(firewall-cmd --permanent --list-ports --zone=$selectedzone 2>/dev/null))
    firewall-cmd --permanent --list-rich-rules --zone=$selectedzone > $temprulefile
    cat $temprulefile
    echo " services :"$services
    arrnum=2
    serviceslen=${#services[0]}
    portslen=${#ports[0]}
    richrules=$(expr length "$(cat richrules.txt)")

      if [[ $serviceslen -eq 0 && $portslen -eq 0 && $portslen -eq 0 ]]
      then

        dialog --title --stdout "dialog" --clear --msgbox "nothing are settings set." 10 30
        funcrlt="nothingset"
        break
      fi
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

        break
        #echo "deleteconfig : "$deleteconfig

      #echo services=
      #echo posts=
      #echo richrules=
      #sleep 1
      #continue
  ;;
esac
done

#echo "1val :"$1
#sleep 10

#nullval=' '
#menuvar="${zonevar[0]} ${zonevar[0]} off"

#unset zonevar[0]
#for arg in ${zonevar[@]}
#do
#echo "var : "$arg
#menuvar="$menuvar $arg $arg off"
#done
#echo "$menuvar"
#setconfig=$(dialog --stdout --clear --title "select zone or makezone" \
#    --radiolist "zone list" 20 60 4  \
#    "delete zone" "delete custom zone" on \
#    "make zone" "makezone and change default zone" on \
#    $menuvar \

 #   "EXIT"  "EXIT" off)
#    retval=$?
#echo "retval : "$retval
#if [[ $retval -ne "0" ]]
#then
#  setconfig="cancel"
#fi
#echo "setconfig : "$setconfig

}
########################################################## main process ############################################################
while true
do
selectzone
          echo "setconfig : "$setconfig
case $setconfig in
  "cancel")
  dialog --title --stdout "My first dialog" --clear --msgbox "select cancel" 10 30
  echo "Good Bye~"
  break
    ;;
  "make zone")
        while true
        do
          makezone
          retval=$?
          echo "retval : "$retval
          echo "zonename : "$zonename
            if [[ $zonename = "" ]]
            then
              echo "invalid zonename"
              sleep 1
              continue
            elif [[ $zonename = "select cancel" ]]
            then
              dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
              break
            else
              dialog --title --stdout "My first dialog" --clear \
                        --yesno "is \"$zonename\" your input zone name?" 10 30
                case $? in
                0)
                  echo "sh setfirewall.sh " "$setconfig" "$zonename"
                  getresult=$(sh setfirewall.sh "$setconfig" "$zonename")
                  echo "getresult :"$getresult
                    if [[ $getresult != "success" ]]
                    then
                      dialog --title --stdout "error cause" --clear --msgbox "\"$getresult\" error is caused!" 10 30
                    else
                      dialog --title --stdout "My first dialog" --clear --msgbox "\"$zonename\" is maked!" 10 30
                      break
                    fi
                ;;
                1)
                  echo "cancel"
                  continue
                ;;
                esac
            fi
        done
  continue
  ;;
  "delete zone")
        removezoneorconfig "delete zone"
              echo "funcrlt : "$funcrlt
            if [[ $funcrlt == "cancel" ]]
            then
              echo "cancel selected"
              dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
              sleep 1
              continue
            elif [[ $funcrlt != "cancel" ]]
            then
              echo "deletezone :" $deletezone
              echo "sh setfirewall.sh " "deletezone" "$deletezone"
              getresult=$(sh setfirewall.sh "deletezone" "$deletezone")
              echo "getresult :"$getresult
                if [[ $getresult != "success" ]]
                then
                  dialog --title --stdout "error cause" --clear --msgbox "\"$getresult\" error is caused!" 10 30
                else
                  dialog --title --stdout "My first dialog" --clear --msgbox "delete zone success!" 10 30
                  continue
                fi
            continue
            fi
  continue
  ;;
  * )
    setfirewalld $setconfig
    sleep 1
    continue
  ;;
esac

done
exit 0


