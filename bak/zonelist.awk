#!/usr/local/bin/awk -f
#echo $(firewall-cmd --get-zones) | awk -f awk.wk
BEGIN { i=1; } {while (i<=11) {  
if (($i != "block") && ($i != "dmz") && ($i != "drop") && ($i != "external") && ($i != "home") && ($i != "internal") && ($i != "public") && ($i != "trusted") && ($i != "work")) {
print $i; 
}
i++ }}
