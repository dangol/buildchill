# Turn off IPV6: https://support.microsoft.com/en-us/help/929852/guidance-for-configuring-ipv6-in-windows-for-advanced-users
$INTFC=Get-NetAdapterBinding -ComponentID ms_tcpip6
Disable-NetAdapterBinding -Name $INTFC.Name -ComponentID ms_tcpip6
# Get-NetAdapter -Name $INTFC.Name | Get-NetIPConfiguration
# Set host static IP address
if ($env:computername.EndsWith('P','CurrentCultureIgnoreCase')) {$IP = "10.31.1.10"}
elseif ($env:computername.EndsWith('B','CurrentCultureIgnoreCase')) {$IP = "10.31.1.11"}
else { write-host "Name does not end with P or B can't determine roll, failed" }
$MaskBits = 24 # This means subnet mask = 255.255.255.0
$Gateway = "10.31.1.1"
$Dns = "10.31.1.10","10.31.1.11"
$IPType = "IPv4"
# Retrieve the network adapter to configure
$adapter = Get-NetAdapter | ? {$_.Status -eq "up"}
# Remove any existing IP, gateway from ipv4 adapter
If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
 $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
}
If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
 $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
}
 # Configure the IP address and default gateway
$adapter | New-NetIPAddress `
 -AddressFamily $IPType `
 -IPAddress $IP `
 -PrefixLength $MaskBits `
 -DefaultGateway $Gateway
# Configure the DNS client server IP addresses
$adapter | Set-DnsClientServerAddress -ServerAddresses $DNS