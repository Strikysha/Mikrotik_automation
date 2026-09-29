# provision_router.rsc
# Bootstraps this repo's RouterOS side onto a Mikrotik router from scratch:
# creates the bynets_v4/bynets_v6 scripts (kept in sync with bynets_v4.rsc /
# bynets_v6.rsc in this repo) and the scheduler jobs that run them daily,
# so the router keeps re-fetching IPv4_list.txt/IPv6_list.txt that the
# fetch_ip_lists.yml GitHub Action refreshes every day at 00:00 UTC.
#
# Usage: upload this file to the router (Files) and run:
#   /import file-name=provision_router.rsc
# It is idempotent - safe to re-run after wiping the scripts/scheduler.

:log info "provision_router: (re)installing bynets_v4/bynets_v6 scripts and scheduler jobs";

/system script remove [find name=bynets_v4];
/system script remove [find name=bynets_v6];

/system script add name=bynets_v4 owner=Strikysha policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source={
## Generic IP address list input
## Script written by Yury V, 2008
# lpref = prefix; llist = suffix (and the name of file to fetch)
:local lpref "bynets_v4";
:local lname "IPv4_list";
:local llist "$lpref";
:local lfile "$lname.txt";

/tool fetch address=raw.githubusercontent.com host=raw.githubusercontent.com mode=https src-path="Strikysha/Mikrotik_automation/refs/heads/main/$lfile"
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
}

/system script add name=bynets_v6 owner=Strikysha policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon source={
## Generic IP address list input
## Script written by Yury V, 2008
# lpref = prefix; llist = suffix (and the name of file to fetch)
:local lpref "bynets_v6";
:local lname "IPv6_list";
:local llist "$lpref";
:local lfile "$lname.txt";

/tool fetch address=raw.githubusercontent.com host=raw.githubusercontent.com mode=https src-path="Strikysha/Mikrotik_automation/refs/heads/main/$lfile"
:delay 10 ;
:if ( [/file get [/file find name="$lfile"] size] > 0 ) do={
# Remove existing addresses from the current Address list
/ipv6 firewall address-list remove [/ipv6 firewall address-list find list=$llist]

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
 /ipv6 firewall address-list add list=$llist address="$entry"
 }
 }
} while ($lineEnd+1 < $contentLen)
# CUSTOM entries here
#/ip firewall address-list add list=$llist address="1.1.1.1/32" comment="$date $time host via byfly is faster"
}
}

/system scheduler remove [find name=bynets_v4];
/system scheduler remove [find name=bynets_v6];

# Router timezone is Europe/Vilnius; the GitHub Action commits fresh lists
# daily at 00:00 UTC (02:00-03:00 local depending on DST), so 04:00/04:05
# local leaves a safe buffer.
/system scheduler add name=bynets_v4 interval=1d start-time=04:00:00 on-event="/system script run bynets_v4" comment="Refreshes bynets_v4 address-list from IPv4_list.txt (see bynets_v4.rsc)";
/system scheduler add name=bynets_v6 interval=1d start-time=04:05:00 on-event="/system script run bynets_v6" comment="Refreshes bynets_v6 address-list from IPv6_list.txt (see bynets_v6.rsc)";

:log info "provision_router: done";
