#!/bin/bash
export NCURSES_NO_UTF8_ACS=1
#trap "echo \"find interrupt\" ; exit 0" 0 1 2 24
trap "exit 0" 0 1 2 24
SETCONFIG=
function CONFIGSELECT()
{
SETCONFIG=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice config menu" 20 51 4 \
        "set user" "" ON \
        "check/fix vulnerability" "" off \
        "EXIT"  "EXIT" off)
echo $SETCONFIG
sleep 1
}
function setuser()
{
USERVALUES=($(dialog  --stdout --title "Make User" --clear \
--form "\nPlease Input Username and User password" 25 60 16 \
"Username:" 1 1 "" 1 15 30 30 \
"Password:" 2 1 "" 2 15 30 30))
RETVAL=$?
          echo "111111111111111111111111111"
          echo "RETVAL : "$RETVAL
          echo ${#USERVALUES[*]}
          echo "USERVALUES0 : "${#USERVALUES[*]}
          echo "USERVALUES0 : "${USERVALUES[0]}
          echo "USERVALUES1 : "${USERVALUES[1]}
#if [ ${#USERVALUES[*]} -eq "0" ] || [[ ${USERVALUES[0]} = "" ]] || [[ ${USERVALUES[1]} = "" ]]
#then
#echo "INVALID VALUE INPUT!!"
#else
#echo "process"
#fi

SETUSERLT=
if [[ $RETVAL -ne "0" ]]
then
SETUSERLT="select cancel"
fi
}

while true # 무한 루프.
do
CONFIGSELECT
#RETVAL=$?

echo "SETCONFIG : "$SETCONFIG

case $SETCONFIG in
  EXIT)
  echo "Good Bye~"
  break
    ;;
  "set user")
      while true # 무한 루프.
      do
          setuser
          echo "22222222222222222222222222222"
          echo ${#USERVALUES[*]}
          echo "USERVALUES0 : "${#USERVALUES[*]}
          echo "USERVALUES0 : "${USERVALUES[0]}
          echo "USERVALUES1 : "${USERVALUES[1]}
          echo "?????" $SETUSERLT
                  if [[ $SETUSERLT = "select cancel" ]]
                  then
                    dialog --title --stdout "dialog" --clear --msgbox "select cancel" 10 30
                    break
                  else
                        if [[ ${#USERVALUES[*]} -eq "0" ]] || [[ ${USERVALUES[0]} = "" ]] || [[ ${USERVALUES[1]} = "" ]]
                        then
                          ##echo "INVALID VALUE INPUT"
                          dialog --title --stdout "error cause" --clear --msgbox "INVALID VALUE INPUT" 10 30
                          continue
                        else
                          USEREXIST=$(sed -n "/${USERVALUES[0]}/p" /etc/passwd | awk -F: '{ print $1 }')
                          echo "USEREXIST :" $USEREXIST
                          sleep 1
                            if [[ ${USEREXIST} != "" ]]
                            then
                              dialog --title --stdout "error cause" --clear --msgbox "${USERVALUES[0]} ALEADY EXITS USER" 10 30
                              echo "${USERVALUES[0]} ALEADY EXITS USER"
                              sleep 1
                              continue
                            else
                              useradd ${USERVALUES[0]}
                              USERADDRLT=$?
                              echo $?
                                if [[ $USERADDRLT -ne "0" ]]
                                then
                                  echo "USER ADD FAIL, CHECK SCRIPT debuging) #!/bin/bash -x"
                                  sleep 1
                                else
                                  echo ${USERVALUES[1]} | passwd ${USERVALUES[0]} --stdin
                                  #echo "${USERVALUES[0]} USER ADD SUCCESS INIT PASSWORD IS USERID"
                                  #sleep 1
                                  dialog --title --stdout "USER ADD SUCCESS" --clear --msgbox "${USERVALUES[0]} USER ADD SUCCESS" 10 30
                                  break
                                fi
                            fi
                        fi
                  fi
      done
          ;;
  "check/fix vulnerability")
#echo "check/fix vulnerability"
    COUNT=0
    while [ $COUNT != 100 ]
    do
    COUNT=$(expr $COUNT + 25)
    args=$COUNT
    echo $COUNT
    sleep 1
    done | dialog --title "Checking..." --gauge "Checking and Fix VULNERABILITY" 20 70 0
    dialog --title --stdout "VULNERABILITY Check Success" --clear --msgbox "VULNERABILITY Check Success" 10 30
  continue
  #setfirewalld
  #continue
    ;;
  * )
  sleep 1
  break
  #  ;;
esac
done
exit 0
