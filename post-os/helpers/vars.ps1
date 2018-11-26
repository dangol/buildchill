# Variables for all custom scripts
# *********Edit this section***********
$ROLE = 'GAMESERVERA' #Determines Primary, GAMESERVERA, or Backup, GAMESERVERB configuration
$ScopId = '10.100.1.0' #Sets the DHCP scope and reverse DNS scope
$RangeEnd = '10.100.1.250' #Sets the END of the DHCP scope range
$RangeStart = '10.100.1.50' #Sets the START of the DHCP scope range
$SubnetMask = '255.255.255.0' # sets all references to the subnet mask
$LeaseDuration = '8:0:0:0' # length of a DHCP lease
$DNS1 = '10.100.1.10' # Primary host ip
$DNS2 = '10.100.1.11' # backup host ip
$Router = '10.100.1.1' # default gateway
$rzone = '1.100.10.in-addr.arpa' # reverse dns
$DomainName = 'castlehillgaming.local' # domain name to use
$ScopeOptionValue = '"gameservera gameserverb"' # order of scope options
$PrimaryGame = "gameservera" # primary name
$SecondaryGame = "gameserverb" # backup name
# **********End Editing here!************
