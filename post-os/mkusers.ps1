# Create local users

If (Test-Path $INPATH\helpers\data.ps1) {
  . $INPATH\helpers\data.ps1
} Else {
  write-host "Variables file not found!"
  exit
  } 
$PSWD=ConvertTo-SecureString $PSWD -AsPlainText -Force
write-host "Creating local users, and adding them to the Admin group"
$ITER=$UNAMES.split(",");
foreach($i in $ITER) {
    New-LocalUser -Name $i -Password $PSWD -PasswordNeverExpires -AccountNeverExpires
	Add-LocalGroupMember -Group "Administrators" -Member $i
	}
 
