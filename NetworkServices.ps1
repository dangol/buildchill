# Begin Function Definitions
###############################################################################
function createvars {
  $VARS=@'
  # Variables for all custom scripts
  # *********Edit this section***********
  $ROLE = 'GAMESERVERP' #Determines Primary, GAMESERVERP, or Backup, GAMESERVERB configuration
  $ScopId = '10.31.1.0' #Sets the DHCP scope and reverse DNS scope
  $RangeEnd = '10.31.1.250' #Sets the END of the DHCP scope range
  $RangeStart = '10.31.1.50' #Sets the START of the DHCP scope range
  $SubnetMask = '255.255.255.0' # sets all references to the subnet mask
  $LeaseDuration = '8:0:0:0' # length of a DHCP lease
  $DNS1 = '10.31.1.10' # Primary host ip
  $DNS2 = '10.31.1.11' # backup host ip
  $Router = '10.31.1.1' # default gateway
  $rzone = '1.31.10.in-addr.arpa' # reverse dns
  $DomainName = 'castlehillgaming.local' # domain name to use
  $ScopeOptionValue = '"gameserverp gameserverb"' # order of scope options
  $PrimaryGame = "gameserverp" # primary name
  $SecondaryGame = "gameserverb" # backup name
  # **********End Editing here!************
'@
  set-content .\vars.ps1 $VARS
}

function installDHCP {
  # Test if DHCP server is already installed and install if not
  $feat = Get-WindowsFeature -Name DHCP
  if ($feat.Installed -Match "False") {add-windowsfeature -IncludeManagementTools dhcp}
}

function installDNS {
  # Test if DNS server is already installed and install if not
  $feat = Get-WindowsFeature -Name Dns
  if ($feat.Installed -Match "False") {add-windowsfeature -IncludeManagementTools DNS}
}

function primaryDHCP {
  # Post install wizard steps Creating
  #Creating DHCP security groups
  netsh dhcp add securitygroups
  Restart-service dhcpserver
  #Create scope range
  Add-DhcpServerv4Scope -EndRange $RangeEnd -Name Scope -StartRange $RangeStart -SubnetMask $SubnetMask -LeaseDuration $LeaseDuration
  #configure scope values
  set-DhcpServerv4Optionvalue -Force -ScopeId $ScopId -dnsserver $DNS1,$DNS2 
  set-DhcpServerv4Optionvalue -ScopeId $ScopId -Router $Router
  set-DhcpServerv4Optionvalue -ScopeId $ScopId -DnsDomain $DomainName
  #Setup option 77 for game discovery
  $ErrorActionPreference = "SilentlyContinue"
  $opt=get-DhcpServerv4OptionDefinition -Optionid 77 -VendorClass "Microsoft Options"
  if ($opt.multivalued -Match "True") {remove-DhcpServerv4OptionDefinition -OptionId 77 -VendorClass "Microsoft Options"}
  Add-DhcpServerv4OptionDefinition -Name "CHG-Game-Server" -VendorClass "Microsoft Options" -OptionId "77" -Type String -MultiValue
  Set-DhcpServerv4OptionValue -OptionId 77 -ScopeId $ScopId -VendorClass "Microsoft Options" -Value $ScopeOptionValue
  $ErrorActionPreference = "Continue"
  # This completes setup of DHCP server, scope and options
}

function primaryDNS {
  # Create the primaryZone
  Add-DnsServerPrimaryZone -Name $DomainName -ZoneFile $DomainName
  Set-DnsServerPrimaryZone -Name $DomainName -SecureSecondaries TransferToSecureServers -SecondaryServers $DNS2

  # Create the reverse Zone
  Add-DnsServerPrimaryZone -NetworkID $ScopID/24 -ZoneFile $ScopID
  
  #Populate Zones 
  Add-DnsServerResourceRecordA -Name $PrimaryGame -ZoneName $DomainName -IPv4Address $DNS1 -TimeToLive 01:00:00 -CreatePTR
  Add-DnsServerResourceRecordA -Name $SecondaryGame -ZoneName $DomainName -IPv4Address $DNS2 -TimeToLive 01:00:00 -CreatePTR
}

function secondaryDHCP {
  # Post install wizard steps Creating
  #Creating DHCP security groups
  netsh dhcp add securitygroups
  Restart-service dhcpserver
  #Setup option 77 for game discovery
  $opt=get-DhcpServerv4OptionDefinition -Optionid 77 -VendorClass "Microsoft Options"
  if ($opt.multivalued -Match "True") {remove-DhcpServerv4OptionDefinition -OptionId 77 -VendorClass "Microsoft Options"}
  Add-DhcpServerv4OptionDefinition -Name CHG-Game-Server -VendorClass "Microsoft Options" -OptionId 77 -Type String -MultiValue
  # Setup failover
  Add-DhcpServerv4Failover -ComputerName gameservera -Name SFO-SIN-Failover -PartnerServer gameserverb.castlehillgaming.local -ScopeId $ScopId -ReservePercent 10 -MaxClientLeadTime 2:00:00 -AutoStateTransition $true -StateSwitchInterval 2:00:00
}

function secondaryDNS {
  ### For Secondary Server ###
  Add-DnsServerSecondaryZone -Name $DomainName -ZoneFile $DomainName -MasterServers $DNS1 
  Add-DnsServerSecondaryZone -MasterServers $DNS1 -NetworkId $ScopId/24 -ZoneFile $DomainName
}
# End Function Definitions
###############################################################################
# Verify vars file can be found
echo "Gettings Vars file"
If (Test-Path vars.ps1){
  . .\vars.ps1
}Else{
  write-host "Variables file not found!"
  createvars
  write-host 'Create file vars.txt, correct the values in the file and then run again!'
  exit
}

# Script Body starts
write-host $ROLE
# Set domain search for instance
(Get-WmiObject -Class win32_networkadapterconfiguration |  ?{$_.IPAddress -like $DNS1 -or $_.IPAddress -like $DNS2}).SetDNSDomain($DomainName)
# Call installation functions
$idns=installDNS
$idhcp=installDHCP

if ($ROLE -eq 'GAMESERVERP'){
  write-host 'Running $ROLE'
  $dnsA=primaryDNS
  $dhcpA=primaryDHCP
  write-host 'Complete!'  
}
if ($ROLE -eq 'GAMESERVERB'){
  write-host 'Running $ROLE'
  $dnsB=secondaryDNS
  $dhcpB=secondaryDHCP
  write-host 'Complete!' 
}
# Script Body ends