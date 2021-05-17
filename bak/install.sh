#!/bin/sh

DIALOG=${DIALOG=dialog}
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
trap "exit 0" 0 1 2 5 15
arrayvar=
function packageselect()
{

    var=(dialog --stdout --clear --title "My  favorite HINDI singer"
    --checklist "Hi, Choose  your package  HINDI singer:" 20 51 4 )
        "confluence(atlassian)"  "confluence" ON \
        "jira(atlassian)"  "jira" off \
        "Laravel"  "Laravel" off \
        "EXIT"  "EXIT" off >/dev/tty 2>&1
arrayvar=var
}
packageselect

echo "var01 의 길이 = ${#arrayvar}"

sleep 30
while true # 무한 루프.
do
packageselect
retval=$?

choice=`cat $tempfile`

case $choice in
  EXIT)
  echo "'$choice' is your choice package"
  echo "Good Bye~"
  break
    ;;
  1)
    echo "Cancel pressed.";;
   * )
  printf '\n\nYou chose: %s\n' "${array[var - 1]}"
  sleep 1
  continue
    ;;
esac

done