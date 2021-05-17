#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
TEMPFILE=portset
ORIFS=$IFS
trap 'rm -f "$TEMPFILE"' 0 1 2 24
trap "echo \"find interrupt\" ; exit 0" 0 1 2 24
TEMPRULEFILE=richrules.txt
trap 'rm -f "$TEMPRULEFILE" ; exit 0' 0 1 2 24
systemctl status firewalld.service 1>/dev/null
CHKSRV=$?
if [[ $CHKSRV != "0" ]]
then
echo "firewall service is not running"
exit 0
fi
COUNT=0;

function MAKEZONE()
{
ZONENAME=$(dialog --stdout --title "Input zone Name" --clear \
        --inputbox "Please input zone name" \
        16 51 ""
        )
RETVAL=$?
if [[ $RETVAL -ne "0" ]]
then
ZONENAME="select cancel"
fi

}
function SETRICHRULE()
{
SETRICHRULERLT=0
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
(( NUM++ ))
done < $TEMPFILE
}
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
function SETFIREWALLD()
{
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
      case $FIREWALLCHKCONFIG in
      0)
          case $SETPORT in
          "RICH RULE")
              while true
              do
                SETRICHRULE
                  STARTPORTCHK=$(echo "${RICHCONFIGS[0]}" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)
                  ENDPORTCHK=$(echo "${RICHCONFIGS[1]}" | grep -o "\(^[^0^a-z^A-Z]\{1,1\}[0-9]\{1,1\}[0-9]\{0,1\}[0-9]\{0,1\}$\)" | wc -l)
                  if [[ $SETRICHRULERLT = "select cancel" ]]
                  then
                    dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
                    break
                  else
                      if [[ ${#RICHCONFIGS[*]} -eq "3" ]]
                      then
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
                      dialog --title --stdout "Check input port" --clear \
                            --yesno "Is \"$CUSTOMPORT\" your input port?" 10 30
                          case $? in
                          0)
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

function SELECTZONE()
{
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
    SERVICES=($(firewall-cmd --permanent --list-services --zone=$SELECTEDZONE 2>/dev/null))
    PORTS=($(firewall-cmd --permanent --list-ports --zone=$SELECTEDZONE 2>/dev/null))
    firewall-cmd --permanent --list-rich-rules --zone=$SELECTEDZONE > $TEMPRULEFILE
    cat $TEMPRULEFILE
    ARRNUM=2
    SERVICESLEN=${#SERVICES[0]}
    PORTSLEN=${#PORTS[0]}
    RICHRULES=$(expr length "$(cat $TEMPRULEFILE)")

      if [[ $SERVICESLEN -eq 0 && $PORTSLEN -eq 0 && $RICHRULES -eq 0 ]]
      then
        dialog --title --stdout "REMOVE CONFIG" --clear --msgbox "nothing is set" 10 30
        FUNCRLT="nothingset"
        break
      fi
        IFS=$'\n'
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


