#!/bin/bash
TARGETPATH=targetconfig
CHECKRESULT=targetconfig/vulcheckresult.txt
if [ -e "$CHECKRESULT" ]
then
    echo "file extis"
else
    echo "file not extis"
    exit 0
fi
RHELVER=$(awk '{ print $4 }' /etc/redhat-release | awk -F. '{ print $1 }')
#RHELVER=5
EXITSCONFIG=
PWCOMPRLT=$(sed -n '/PASSWORD COMPLEXITY : DETECTED/p' $CHECKRESULT)
echo "PWCOMPRLT: "$PWCOMPRLT

if [[ RHELVER -eq "5" ]]
then
    if [[ -z "$PWCOMPRLT" ]] # value is null
    then
        echo "NO PASSWORD COMPLEXITY VULNERABILITY DETECTED."
    else
        #echo "cat -n $TARGETPATH/system-auth_test |sed -n '/password    requisite     pam_cracklib.so/p' | awk '{ print $1 }'"
        EXITSCONFIG=$(cat -n $TARGETPATH/system-auth_test |sed -n '/password    requisite     pam_cracklib.so/p' | awk '{ print $1 }')
        if [[ -n "$EXITSCONFIG" ]] # value is not null
        then
            ex $TARGETPATH/system-auth_test +/"password    requisite     pam_cracklib.so"/ +'d' +'i|password    requisite     pam_cracklib.so try_first_pass retry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 difok=N'  -s +'1,$|w|q!'  1 > /dev/null
        else
            ex $TARGETPATH/system-auth_test +/"password    required"/ +'i|password    requisite     pam_cracklib.so try_first_pass retry=3 minlen=8 lcredit=-1 ucredit=-1 dcredit=-1 difok=N'  -s +'1,$|w|q!'  1 > /dev/null
        fi

    fi
fi
EXITSCONFIG=
PWCOMPRLT=$(sed -n '/PASSWORD COMPLEXITY : DETECTED/p' $CHECKRESULT)
if [[ RHELVER -eq "7" ]]
then
    if [[ -z "$PWCOMPRLT" ]] # value is null
    then
    echo "NO PASSWORD COMPLEXITY VULNERABILITY DETECTED."
    else
        CHKVALUE=("# retry = 3" "# minlen = -1" "# lcredit = -1" "# ucredit = -1" "# dcredit = -1" "# difok = N")
          ELEMENT_COUNT=${#CHKVALUE[@]}
          INDEX=0
            while [ "$INDEX" -lt "$ELEMENT_COUNT" ]
            do
                FINDTEXT=$(echo "${CHKVALUE[$INDEX]}" | awk '{ print $1" "$2" "$3 }')
                EXITSCONFIG=$(cat -n $TARGETPATH/pwquality.conf_test |sed -n "/$FINDTEXT/p" | awk '{ print $1 }')

                if [[ -n "$EXITSCONFIG" ]] # value is not null
                then
                    CHGTEXT=$(echo "${CHKVALUE[$INDEX]}" | awk '{ print $2" "$3" "$4 }')
                    sed -i "s/$FINDTEXT/$CHGTEXT/g" $TARGETPATH/pwquality.conf_test
                else
                    CHGTEXT=$(echo "${CHKVALUE[$INDEX]}" | awk '{ print $2" "$3" "$4 }')
                    sed -i "/# dictpath =/a $CHGTEXT" $TARGETPATH/pwquality.conf_test
                fi
                let "INDEX = $INDEX + 1"
            done
    fi
fi
