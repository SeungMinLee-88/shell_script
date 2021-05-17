#!/bin/bash
NO_ARGS=0
OPTERROR=65
#[root@master ~]# ./getopts.sh -b -ez -a -b -c -exz -a -b
if [ $# -eq "$NO_ARGS" ]
then
 echo "usage: `basename $0` options (-mnopqrs)"
 exit $OPTERROR
fi
while getopts "abcde:fg" Option
# 초기 선언.
# a, b, c, d, e, f, g 옵션(플래그)만 지원.
# 'e' 뒤의 :로 'e' 옵션에는 인자가 있어야 된다는 것을 나타냄
do
 case $Option in
 a ) echo "aaa"
;;
 b ) echo "bbb"
;;
 c ) echo "ccc"
;;
 d ) echo "ddd"
;;
 e ) #echo "eee / $OPTARG"
     case $OPTARG in
      z ) echo "z option select"
        ;;
      x ) echo "x option select"
      ;;
    esac
;;
 f ) echo "fff / -$Option-"
;;
 g ) echo "ggg / -$Option-"
;;

 * ) echo "default"
;;
 esac
echo "OPTIND : "$OPTIND
done
echo "OPTIND : "$OPTIND
echo "OPTIND -1 : "$(($OPTIND - 1))
#shift $(($OPTIND - 1))