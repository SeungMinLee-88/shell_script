#!/bin/bash
TARGETPATH=targetconfig
CHECKRESULT=targetconfig/vulcheckresult.txt
# 검출된 취약점을 처리하는 스크립트이다.
if [ -e "$CHECKRESULT" ]
then
    echo "file extis"
else
    echo "file not extis"
    exit 0
fi
# awk 명령으로 OS의 주요 버전을 찾는다.
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
		# cat의 출력 결과를 sed 명령을 전달한다.
        EXITSCONFIG=$(cat -n $TARGETPATH/system-auth_test |sed -n '/password    requisite     pam_cracklib.so/p' | awk '{ print $1 }')
        if [[ -n "$EXITSCONFIG" ]] # value is not null
        then
		    # ex 명령어로 파일의 내용을 치환하거나 원하는 라인데 내용을 추가한다.
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
				    # sed 명령어로 파일의 내용을 치환하거나 원하는 라인데 내용을 추가한다.
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
