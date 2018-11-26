# Configure WCF features

$WCF='NET-WCF-HTTP-Activation45,NET-WCF-MSMQ-Activation45,NET-WCF-TCP-Activation45'
$ITER=$WCF.split(",");
foreach($i in $ITER) {
	$feat = Get-WindowsFeature -Name $i
  if ($feat.Installed -Match "False") {add-windowsfeature $i}
}