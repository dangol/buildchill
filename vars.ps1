  # Variables for all custom scripts
  # *********Edit this section***********
  $ROLE = 'GAMESERVERB' #Determines Primary, GAMESERVERA, or Backup, GAMESERVERB configuration
  $ScopId = '10.0.2.0' #Sets the DHCP scope and reverse DNS scope
  $RangeEnd = '10.0.2.250' #Sets the END of the DHCP scope range
  $RangeStart = '10.0.2.51' #Sets the START of the DHCP scope range
  $SubnetMask = '255.255.255.0' # sets all references to the subnet mask
  $LeaseDuration = '8:0:0:0' # length of a DHCP lease
  $DNS1 = '10.0.2.15' # Primary host ip
  $DNS2 = '10.0.2.50' # backup host ip
  $Router = '10.0.2.2' # default gateway
  $rzone = '2.0.10.in-addr.arpa' # reverse dns
  $DomainName = 'castlehillgaming.local' # domain name to use
  $ScopeOptionValue = '"gameservera gameserverb"' # order of scope options
  $PrimaryGame = "gameservera" # primary name
  $SecondaryGame = "gameserverb" # backup name
  # **********End Editing here!************
