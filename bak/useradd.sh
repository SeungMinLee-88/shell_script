#!/bin/bash
trap "echo \"find interrupt\" ; exit 0" 0 1 2 24
#this basic input box
#dialog --clear  --help-button --backtitle "Linux Shell Script Dialog Box" --title "[ M A I N - M E N U ]" --menu "Here is the description of the menu\nSelect option" 15 50 4 first "define first function" second "Define second" Third "Define third" Exit "Exit"
function configselect()
{
setconfig=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice config menu" 20 51 4 \
        "adduser" "" ON \
        "setusersecurity" "" off \
        "setfirewall" "" off \
        "EXIT"  "EXIT" off)
echo $setconfig
sleep 1
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
zonename=
function makezone()
{
    echo "12312"
zonename=$(dialog --stdout --title "My input box" --clear \
        --inputbox "Hi, this is a sample input box\n Try entering your name below:" \
        16 51 2
        )
echo zonename
}

setport=
function setfirewalld()
{
while true
do

setport=$(dialog --stdout --clear --title "My  favorite HINDI singer" \
    --radiolist "choice service or range" 20 51 4 \
        "80"  "http" ON \
        "443"  "https" off \
        "8080"  "was" off \
        "22"  "ftp" off \
        "portrange"  "startport-endport" off \
        "make-zone"  "zone-name" off \
        "EXIT"  "EXIT" off)
echo $setport
sleep 1
case $setport in
  EXIT)
  echo "'$setport' is your choice package"
  echo "done"
  break
    ;;
  portrange)
      setportrange
    ;;
   portrange )
     setportrange $setport

  continue
    ;;
  make-zone)
      makezone
    ;;
esac
done
}


OIFS=$IFS; IFS=: # /etc/passwd 는 필드 구분자로 ":"를 씁니다.
while true # 무한 루프.
do
configselect
retval=$?

echo "setconfig : "$setconfig

case $setconfig in
  EXIT)
  echo "'$setconfig' is your choice package"
  echo "Good Bye~"
  break
    ;;
  setfirewall)
  setfirewalld
  continue
    ;;
   * )
  sleep 1
  continue
    ;;
esac
done
