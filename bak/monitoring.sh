#!/bin/bash
# -x
trap "rm -f allcpurlt.txt percpurlt.txt memrlt.txt bandwidth.txt reporttcpdump.txt systemmonreport*.txt; exit 0" 1 2 24
ORIFS=$IFS

if [[ $# -eq "0" ]]
then
 echo "usage: `basename $0` options (-b -u -rcs)"
 exit 0
fi
if [[ $# -eq "1" && $1 == "--help" ]]
then
 echo "usage: `basename $0` options (-b -u -rcs)"
 echo "        -r,  record....."
 exit 0
fi
while getopts "ubr:cscssc:nr" Option
do
 case $Option in
  b )
    #basic monitor
  ;;
  u )
        IFACELIST=("ALL" $(netstat -i | awk 'BEGIN { IF=" " } { if (($1 != "Kernel") && ($1 != "lo") && ($1 != "Iface") ) { print $1 } }'))

        IFACENUM=1
        ALLIFACELIST=
        for ARG in ${IFACELIST[@]}
        do
        echo "$IFACENUM. "$ARG
        ALLIFACELIST=$ALLIFACELIST"-e /$ARG/p "
        (( IFACENUM++ ))
        done

        echo -n "INPUT INTERFACE: "
        read INPUTINTERFACE
        ADRINTERFACE=$((($INPUTINTERFACE - 1)))

        if [[ -z ${IFACELIST[$ADRINTERFACE]} ]]
        then
         echo "Invalid value input!"
         exit 0
        fi
        echo -n "INPUT INTERVAL(Please input a value greater than 2): "
        read INTERVAL
        echo -n "INPUT TOTAL: "
        read ROTATE

        let TOTALTIME=$INTERVAL*$ROTATE
        if [[ INTERVAL -lt "2" ]]
        then
            echo "Invalid INTERVAL input!"
            exit 0
        fi
        if [[ $TOTALTIME -eq "0" ]]
        then
            echo "Invalid value input!"
            exit 0
        fi

        if [[ $TOTALTIME -eq "0" ]]
        then
            echo "Invalid value input!"
            exit 0
        fi
        CNTVAL=1
        SLEEPVAL=`expr $INTERVAL - 1`

          if [[ ${IFACELIST[$ADRINTERFACE]} == "ALL" ]]
          then
            sar $INTERVAL $ROTATE > allcpurlt.txt | mpstat -u -P ALL $INTERVAL $ROTATE > percpurlt.txt | sar -r $INTERVAL $ROTATE > memrlt.txt | sh bandwidth.sh ALL $INTERVAL $ROTATE "$ALLIFACELIST" | sh monitortcpdump.sh ${IFACELIST[$ADRINTERFACE]} $INTERVAL $ROTATE 1>/dev/null 2>/dev/null
          elif [[ ${IFACELIST[$ADRINTERFACE]} != "ALL" ]]
          then
            sar $INTERVAL $ROTATE > allcpurlt.txt | mpstat -u -P ALL $INTERVAL $ROTATE > percpurlt.txt | sar -r $INTERVAL $ROTATE > memrlt.txt | sh bandwidth.sh PER $INTERVAL $ROTATE "-e /${IFACELIST[$ADRINTERFACE]}/p " | sh monitortcpdump.sh ${IFACELIST[$ADRINTERFACE]} $INTERVAL $ROTATE 1>/dev/null 2>/dev/null

          fi
            TIMVAL=$(date +"%Y%m%d%H%M")
            echo "----------------------------------------TOTAL CPU REPORT---------------------------------------" > systemmonreport"$TIMVAL".txt
            echo "                CPU     %user     %nice   %system   %iowait    %steal     %idle" >> systemmonreport"$TIMVAL".txt
            awk ' BEGIN { FS=" " } { if ( $1 =="Average:" ) print $0 }' allcpurlt.txt >> systemmonreport"$TIMVAL".txt
            echo "-----------------------------------------------------------------------------------------------"$'\n' >> systemmonreport"$TIMVAL".txt

            echo "----------------------------------------EACH CPU REPORT----------------------------------------" >> systemmonreport"$TIMVAL".txt
            echo "                CPU     %user     %nice   %system   %iowait    %steal     %idle" >> systemmonreport"$TIMVAL".txt
            awk ' BEGIN { FS=" " } { if ( $1 =="Average:" ) print $0 }' percpurlt.txt >> systemmonreport"$TIMVAL".txt
            echo "------------------------------------------------------------------------------------------------"$'\n' >> systemmonreport"$TIMVAL".txt

            echo "----------------------------------------MEM REPORT----------------------------------------" >> systemmonreport"$TIMVAL".txt
            echo "             kbmemfree kbmemused  %memused kbbuffers  kbcached  kbcommit   %commit  kbactive   kbinact   kbdirty" >> systemmonreport"$TIMVAL".txt
            awk ' BEGIN { FS=" " } { if ( $1 =="Average:" ) print $0 }' memrlt.txt >> systemmonreport"$TIMVAL".txt
            echo "------------------------------------------------------------------------------------------------"$'\n' >> systemmonreport"$TIMVAL".txt

            echo "----------------------------------------BANDWIDTH REPORT----------------------------------------" >> systemmonreport"$TIMVAL".txt
            echo "                IFACE   rxpck/s   txpck/s    rxkB/s    txkB/s   rxcmp/s   txcmp/s  rxmcst/s" >> systemmonreport"$TIMVAL".txt
            awk ' BEGIN { FS=" " } { if ( $1 =="Average:" ) print $0 }' bandwidth.txt >> systemmonreport"$TIMVAL".txt
            echo "------------------------------------------------------------------------------------------------"$'\n' >> systemmonreport"$TIMVAL".txt
            cat reporttcpdump.txt >> systemmonreport"$TIMVAL".txt
          exit 0
  ;;
  r )
     case $OPTARG in
      c )
        echo "apply crontab"
          if [ -f "/etc/cron.d/monitoring" ]
          then
          yes | rm -i /etc/cron.d/monitoring
          fi
          printf "# Run system monitoring tool every 1 hours" >> /etc/cron.d/monitoring
          printf "\n" >> /etc/cron.d/monitoring
          printf "#* */1 * * * sh /root/monitoring.sh -b 1>/dev/null" >> /etc/cron.d/monitoring
          printf "\n" >> /etc/cron.d/monitoring # =echo $'\n'
          crontab /etc/cron.d/monitoring
      ;;
        s )
        echo "apply systemd"
          if [ -f "/etc/systemd/system/monitor.service" ]
          then
          yes | rm -i /etc/systemd/system/monitor.service
          fi
          printf "[Unit]
Description=monitor service
Requires=sysstat.service

[Service]
Type=simple
EnvironmentFile=/root/monitor.env
ExecStart=/root/monitoring.sh -b
ExecReload=/root/monitoring.sh -b

[Install]
WantedBy=multi-user.target\n" >> /etc/systemd/system/monitor.service
      ;;
      cs )
        echo "apply crontab"
          if [ -f "/etc/cron.d/monitoring" ]
          then
          yes | rm -i /etc/cron.d/monitoring
          fi
          printf "# Run system monitoring tool every 1 hours" >> /etc/cron.d/monitoring
          printf "\n" >> /etc/cron.d/monitoring
          printf "#* */1 * * * sh /root/monitoring.sh -b 1>/dev/null" >> /etc/cron.d/monitoring
          printf "\n" >> /etc/cron.d/monitoring # =echo $'\n'
          crontab /etc/cron.d/monitoring
        echo "apply systemd"
          if [ -f "/etc/systemd/system/monitor.service" ]
          then
          yes | rm -i /etc/systemd/system/monitor.service
          fi
          printf "[Unit]
Description=monitor service
Requires=sysstat.service

[Service]
Type=simple
EnvironmentFile=/root/monitor.env
ExecStart=/root/monitoring.sh -b
ExecReload=/root/monitoring.sh -b

[Install]
WantedBy=multi-user.target\n" >> /etc/systemd/system/monitor.service
      ;;
      sc )
        echo "apply systemd"
          if [ -f "/etc/systemd/system/monitor.service" ]
          then
          yes | rm -i /etc/systemd/system/monitor.service
          fi
          printf "[Unit]
Description=monitor service
Requires=sysstat.service

[Service]
Type=simple
EnvironmentFile=/root/monitor.env
ExecStart=/root/monitoring.sh -b
ExecReload=/root/monitoring.sh -b

[Install]
WantedBy=multi-user.target\n" >> /etc/systemd/system/monitor.service
        echo "apply crontab"
          if [ -f "/etc/cron.d/monitoring" ]
          then
          yes | rm -i /etc/cron.d/monitoring
          fi
          printf "# Run system monitoring tool every 1 hours" >> /etc/cron.d/monitoring
          printf "\n" >> /etc/cron.d/monitoring
          printf "#* */1 * * * sh /root/monitoring.sh -b 1>/dev/null" >> /etc/cron.d/monitoring
          printf "\n" >> /etc/cron.d/monitoring # =echo $'\n'
          crontab /etc/cron.d/monitoring
      ;;
      * )
        echo "invalid c option following"
        exit 0
      ;;
    esac
  ;;
 * ) echo "invalid option"
;;
 esac
done
exit 0
