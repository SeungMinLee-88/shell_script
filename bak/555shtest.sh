#!/bin/bash


#TIMVAL=$(date +"%Y%m%d%H%M")
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


trap "echo \"find interrupt\" ; exit 0" 0 1 2 24
echo %s

echo -n "input interval"
read INTERVAL
echo -n "input total"
read ROTATE
echo "1st val : "$INTERVAL
echo "second val : "$ROTATE

let TOTALTIME=$INTERVAL*$ROTATE
echo "TOTALTIME : "$TOTALTIME
CNTVAL=1
#let SLEEPVAL=$INTERVAL-1
SLEEPVAL=`expr $INTERVAL - 1`
echo "SLEEPVAL : "$SLEEPVAL
#exit 0
while (( CNTVAL <= TOTALTIME ))
do
sleep $SLEEPVAL
timeout 1 tcpdump -nni enp0s3 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and dst 192.168.56.2 and tcp'
(( CNTVAL+=INTERVAL ))
echo "CNTVAL : "$CNTVAL
done

#sar 1 10 & timeout 10 tcpdump -nni enp0s3 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and dst 192.168.56.2 and tcp'


exit 0

#systemctl list-unit-files | grep -e enabled -e nework
#IPPORTCNT=
#for arg in $(cat uniqipdump)
#do
#echo "var : "$arg
#IPPORTCNT=$(echo $arg | awk ' BEGIN { FS="."} END { OFS="."; print $1,$2,$3,$4,$5; } ')
#IPPORTCNT=$IPPORTCNT"."$(awk 'BEGIN { ipcnt=0; }  { if ( $1 == "'$arg'" ) {ipcnt++; } }  END { print ipcnt; } ' exptipdump)
#echo $IPPORTCNT | awk ' BEGIN { FS="."} END { OFS="."; print "IP ", $1,$2,$3,$4 " | PORT: " $5 " | REQ: " $6; } ' >> reporttcpdump.txt
#done
#
#
#exit 0

# 'read' 문에서(역시 일종의 할당임)
read line1
read line2
echo "line1 : "$line1
echo "line2 : "$line2

#check number value
#case $string in
#    ''|*[!0-9]*) echo bad ;;
#    *) echo good ;;
#esac
#for 루프처럼 while도 이중소괄호를 써서 C 형태의 문법을 적용할 수 있
#while [ "$a" -le $LIMIT ]
#do
# echo -n "$a "
# let "a+=1"
#done # 아직은 별로 놀랄게 없네요.
#echo; echo
## 이제 똑같은 것을 C 형태의 문법으로 해 봅시다.
#((a = 1)) # a=1
## 이중 소괄호에서는 변수를 세팅할 때 C 처럼 빈 칸을 넣어도 됩니다.
#while (( a <= LIMIT )) # 이중 소괄호, 변수 앞에 "$"가 없네요.
#do
# echo -n "$a "
# ((a += 1)) # let "a+=1"
# # 역시 되는군요.
# # 이중 소괄호를 쓰면 C 문법처럼 변수를 증가시킬 수 있군요.
#done
#echo
# tcpdump -nni enp0s3 'tcp[tcpflags] & (tcp-fin|tcp-push) != 0 and dst 192.168.56.2 and tcp'  > tcpdump.txt
#awk '{ print $5 }' tcpdump.txt | sort | uniq > extcpdump
#awk ' BEGIN { FS=":" } { print $1 } ' extcpdump
#awk '{ if ( $5 != "" ){ print $5,$7 } }' tcpdump.txt | sort | uniq | awk ' BEGIN { FS=":" } { print $1 } ' > uniqipdump
#awk '{ if ( $5 != "" ){ print $5,$7 } }' tcpdump.txt | sort | uniq | awk ' BEGIN { FS=":" } { print $1 } ' > uniqipdump
#awk '{ if ($5 != "") { print $5,$7 }} ' tcpdump.txt | awk 'BEGIN { FS=":" } { print $1,$2 }' > exptipdump
#awk '{ print $5,$7 } ' tcpdump.txt | sort > reqtypedump
# sed -n '/192.168.56.2.80/p' reqlisttcpdump.txt | wc -l
#cat reqlisttcpdump.txt | sort | uniq | awk ' { print $2 }'
#awk 'BEGIN { FS=": ";ipcnt=0; }  { if ( $1 == "192.168.56.2.80" ) {ipcnt++; } }  END { print ipcnt; } ' reqtypedump
#echo "var : "$arg
#IPPORTCNT=$(echo $arg | awk ' BEGIN { FS="."} END { OFS="."; print $1,$2,$3,$4,$5; } ')
#IPPORTCNT=$IPPORTCNT"."$(awk 'BEGIN { ipcnt=0; }  { if ( $1 == "'$arg'" ) {ipcnt++; } }  END { print ipcnt; } ' exptipdump)
#echo $IPPORTCNT | awk ' BEGIN { FS="."} END { OFS="."; print "IP ", $1,$2,$3,$4 " | PORT: " $5 " | REQ: " $6; } ' >> reporttcpdump.txt

# check interface list
#netstat -i | awk 'BEGIN { IF=" " } { if (($1 != "Kernel") && ($1 != "lo") && ($1 != "Iface") ) { print $1 } }'
#------------------------------------------------------------------------------------------------
#tcpdump manual
#
#https://opensource.com/article/18/10/introduction-tcpdump
#
#https://nxmnpg.lemoda.net/ko/1/tcpdump
#
#https://danielmiessler.com/study/tcpdump/
#https://www.tcpdump.org/manpages/tcpdump.1.html
#https://hackertarget.com/tcpdump-examples/
#
#------------------------------------------------------------------------------------------------
#check interface
#https://stackoverflow.com/questions/596590/how-can-i-get-the-current-network-interface-throughput-statistics-on-linux-unix
#https://unix.stackexchange.com/questions/103241/how-to-use-ifconfig-to-show-active-interface-only
#------------------------------------------------------------------------------------------------
#
#sar, vmstat,
#iostat
#mpstat
#
#sar -n DEV 1 1
#
#tcpdump
#
#lsmod is considered
#https://linuxize.com/post/lsmod-command-in-linux/
#https://www.geeksforgeeks.org/lsmod-command-in-linux-with-examples/
#
#tcpdump
#tcpdump -r outfile-1617028911
# check full tile ls ls --full-time outfile-1617028*
#tcpdump -nni enp0s3 -W 10 -w outfile-%s -G 1
# above command mean enp0s3 interface check and -nn : Don’t resolve hostnames or port names.
#A single (n) will not resolve hostnames. A double (nn) will not resolve hostnames or ports. This is handy for not
# file count limit 10 and -w following filename  -G 1 mean every second occured file make
#
#-------------------------------------------------------------------------------------------------
#cpu - sar -P ALL 1 5
#https://linux.die.net/man/1/sar
#
#mpstat -u -P ALL 1
#https://linux.die.net/man/1/mpstat
#
#mem - sar -r 1 3
#https://linux.die.net/man/1/sar
#
#network -  sar -n DEV 1 3 | sed -n -e '/enp0s3/p' -e '/lo/p'
#
#awk ' BEGIN { FS=" " } { if ( $1 =="Average:" ) print $1 }' networkrlt
#sar -n DEV 1 3 | grep -e enp0s3 -e lo
#sar -n DEV 1 3 | grep -E 'enp0s3|lo'
#
#[root@master system]# netstat -i | awk 'BEGIN { IF=" " } { print $1 }'
#
#
#monitor system
#https://unix.stackexchange.com/questions/55212/how-can-i-monitor-disk-io
#
#iostat, sar
#https://unix.stackexchange.com/questions/261967/where-can-i-find-the-disk-latency-using-iostat-await-svctm-util
#
#send diffrent command to pts at current
#[root@master ~]# sar >/dev/pts/1 & iostat >/dev/pts/2
#
#install sysstat
#yum install -y install sysstat
#
#
#vmstat guide
#https://www.geeksforgeeks.org/vmstat-command-in-linux-with-examples/
#
#vmstat cat /proc/meminfo
#https://unix.stackexchange.com/questions/297591/swap-cache-of-vmstat-vs-swapcached-of-proc-meminfo
#
#free vs vmstat
#https://unix.stackexchange.com/questions/297591/swap-cache-of-vmstat-vs-swapcached-of-proc-meminfo
#
#https://askubuntu.com/questions/517285/what-is-the-difference-between-free-and-vmstat-commands
#
#https://unix.stackexchange.com/questions/313618/command-to-check-cpu-memory-i-o-and-networking-for-a-process
#
#vmstat vs sar
#https://myredhatcertification.wordpress.com/2015/04/07/top-iostat-vmstat-sar/
#https://www.linuxquestions.org/questions/solaris-opensolaris-20/vmstat-vs-sar-495390/
#
#https://hashprompt.blogspot.com/2013/02/sar-and-vmstat-in-linux-solaris.html
#
#dm-0
#https://superuser.com/questions/131519/what-is-this-dm-0-device/131520
#https://unix.stackexchange.com/questions/60091/where-is-the-documentation-for-what-sda-sdb-dm-0-dm-1-mean
#https://unix.stackexchange.com/questions/351327/what-are-these-dm-devices
#https://unix.stackexchange.com/questions/60091/where-is-the-documentation-for-what-sda-sdb-dm-0-dm-1-mean
#
#-p [ { device [,...] | ALL } ]
#The -p option displays statistics for block devices and all their partitions that are used by the system. If a device name is entered on the command line, then statistics for it and all its partitions are displayed. Last, the ALL keyword indicates that statistics have to be displayed for all the block devices and partitions defined by the system, including those that have never been used. Note that this option works only with post 2.5 kernels.
#
#-------------------------------------------------------------------------------------------------
#linux check physical disk
#https://serverfault.com/questions/765302/how-to-move-disk-space-from-centos-home-to-centos-root
#
#https://unix.stackexchange.com/questions/360582/get-simple-list-of-all-disks
#
#iostat dm-0 dm-1
#https://unix.stackexchange.com/questions/351327/what-are-these-dm-devices
#https://unix.stackexchange.com/questions/4561/how-do-i-find-out-what-hard-disks-are-in-the-system
#-------------------------------------------------------------------------------------------------
#
#disk lvm1, lvm2
#https://kit2013.tistory.com/199
#
#How do I find out what hard disks are in the system?
#https://unix.stackexchange.com/questions/4561/how-do-i-find-out-what-hard-disks-are-in-the-system
#
#What are these DM devices(disk lvm)?
#https://unix.stackexchange.com/questions/351327/what-are-these-dm-devices
#https://superuser.com/questions/131519/what-is-this-dm-0-device/131520
#
#add lvm
#https://opensource.com/business/16/9/linux-users-guide-lvm
#(create filesystem)
#https://tunnelix.com/add-and-extend-disk-on-virtual-box-through-lvm/
#
#lvextend
#https://serverfault.com/questions/765302/how-to-move-disk-space-from-centos-home-to-centos-root
#
#check uuid
#blkid
#
#check filesystem
#fsck -N /dev/sda3
#https://phoenixnap.com/kb/fsck-command-linux
#
#Bad magic number in super-block while trying to open /dev/.../root
#https://www.sysnet.pe.kr/Default.aspx?mode=2&sub=0&pageno=0&detail=1&wid=12070
#
#command summary
#lsblk
#blkid
#pvcreate /dev/sdb3
#pvscan -vv
#vgreduce --removemissing --force centos
#lvcreate -l +100%FREE --name extend centos
#mkfs -t xfs /dev/sdb3
#lvremove /dev/centos/extend
#pvremove /dev/sdb3
#vgreduce cenots /dev/sdb3
# parted /dev/sdb3
#lvcreate -l +100%FREE --name extend centos
#
#fstab
#/dev/mapper/centos-extend /backup                       xfs     defaults        0 0
#
#mkfs -t xfs /dev/mapper/centos-extend
#mount /dev/mapper/centos-root /backup/
#
#
#filesystem(ext4, ntfs...)
#https://askubuntu.com/questions/143718/mount-you-must-specify-the-filesystem-type
#
#
#systemd
#https://www.shellhacks.com/systemd-service-file-example/
#https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd
#
#https://stackoverflow.com/questions/62035332/systemd-after-nginx-service-is-not-working
