## Generic IP address list input
## Script written by Yury Vaskaboinikau, 2008
# lpref = prefix; llist = suffix (and the name of file to fetch)
:local lpref "bynets_v4";
:local lname "bynets";
:local llist "$lpref";
:local lfile "$lname.txt";

/tool fetch address=datacenter.by host=datacenter.by mode=http src-path="ip/$lfile"
:delay 10 ;
:if ( [/file get [/file find name="$lfile"] size] > 0 ) do={
# Remove existing addresses from the current Address list
/ip firewall address-list remove [/ip firewall address-list find list=$llist]

:local time [/system clock get time] ;
:local date [/system clock get date] ;
:local content [/file get [/file find name=$lfile] contents] ;
# add new line symbol
:set content ( "$content\n" );

:local newContent [:pick $content 0 [:find $content " "]]
:for i from ([:find $content " "] + 1) to=([:len $content] - 1) do={
  :local char [:pick $content $i]
  :if ($char != " ") do={
    :set newContent ($newContent . $char)
  }
}

:local contentLen [ :len $newContent ] ;

:local lineEnd 0;
:local line "";
:local lastEnd 0;
:local counter 0;

:do {
 :set lineEnd [:find $newContent "\n" $lastEnd ] ;
 :set line [:pick $newContent $lastEnd $lineEnd] ;
#If the line doesn't start with a hash then process and add to the list
#If we start over the beginning, skip!
 :if ( $lineEnd < $lastEnd) do={ :set lineEnd ( $contentLen - 1 ); :set lastEnd ( $contentLen ); :set counter 1234567890; } else { :set lastEnd ( $lineEnd + 1 ); }
 :if ( [:pick $line 0 1] != "#" && [:pick $line 0 1] != "\n" && $counter != 1234567890) do={
 :set lastEnd ( $lineEnd + 1 ) ;

 :local entry [:pick $line 0 ($lineEnd -0) ]
 :if ( [:len $entry ] > 0 ) do={
 :set counter ( $counter + 1 ) ;
 /log info "address list $llist entry $counter added: $entry"
 /ip firewall address-list add list=$llist address="$entry"
 }
 }
} while ($lineEnd+1 < $contentLen)
# CUSTOM entries here
#/ip firewall address-list add list=$llist address="1.1.1.1/32" comment="$date $time host via byfly is faster"
}