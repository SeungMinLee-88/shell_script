#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
trap "exit 0" 0 1 2 24
SETCONFIG=
function CONFIGSELECT()
{
SETCONFIG=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice config menu" 20 51 4 \
        "ADD USER" "" ON \
        "CHECK/FIX VULNERABILITY" "" off \
        "SET FIREWALL" "" off \
        "EXIT"  "" off)
}
function SETUSER()
{
USERVALUES=($(dialog  --stdout --title "Make User" --clear \
--form "\nPlease Input Username and User password" 25 60 16 \
"Username:" 1 1 "" 1 15 30 30 \
"Password:" 2 1 "" 2 15 30 30))
RETVAL=$?

SETUSERLT=
if [[ $RETVAL -ne "0" ]]
then
SETUSERLT="select cancel"
fi
}

while true
do
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
                    dialog --title --stdout "ADD USER" --clear --msgbox "select cancel" 10 30
                    break
                  else
                        if [[ ${#USERVALUES[*]} -eq "0" ]] || [[ ${USERVALUES[0]} = "" ]] || [[ ${USERVALUES[1]} = "" ]]
                        then
                          dialog --title --stdout "error cause" --clear --msgbox "INVALID VALUE INPUT" 10 30
                          continue
                        else
                          USEREXIST=$(sed -n "/${USERVALUES[0]}/p" /etc/passwd | awk -F: '{ print $1 }')
                            if [[ ${USEREXIST} != "" ]]
                            then
                              dialog --title --stdout "ADD USER" --clear --msgbox "${USERVALUES[0]} ALEADY EXITS USER" 10 30
                              echo "${USERVALUES[0]} ALEADY EXITS USER"
                              continue
                            else
                              useradd ${USERVALUES[0]}
                                if [[ $USERADDRLT -ne "0" ]]
                                then
                                  dialog --title --stdout "ADD USER" --clear --msgbox "USER ADD FAIL" 10 30
                                else
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
    VULCHECKRLT=$(sh vulcheck.sh)
    VULFIXRLT=
    VULFIXRLT=$(sh vulfix.sh)
    while [ $COUNT != 100 ]
    do
    COUNT=$(expr $COUNT + 25)
    echo $COUNT
    sleep 1
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
    SETFIRWALLRLT=$(sh firewallconf.sh)
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
