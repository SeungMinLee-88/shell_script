#!/usr/local/bin/awk -f
#echo $(firewall-cmd --get-zones) | awk -f awk.wk
# zone의 리스트 중 변수 할당하고 싶지 않은 값을 구분한다.
BEGIN { i=1; } {while (i<=11) {  
if (($i != "block") && ($i != "dmz") && ($i != "drop") && ($i != "external") && ($i != "home") && ($i != "internal") && ($i != "public") && ($i != "trusted") && ($i != "work")) {
print $i; 
}
i++ }}
