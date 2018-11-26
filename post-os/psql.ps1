# Postgresql
$INPATH='\\remin\shares\psql'
If (Test-Path $INPATH\helpers\data.ps1) {
  . $INPATH\helpers\data.ps1
} Else {
  write-host "Variables file not found!"
  exit
  } 
  write-host "Installing PostgresSql with options file"
& $INPATH\apps\postgresql-9.3.24-2-windows-x64 --optionfile $INPATH\helpers\psql.options | out-null
write-host "Complete!"
write-host "Stop DB and adjust settings"
stop-service postgres*
#$conf=.\postgres.conf
$conf='c:\program files\postgresql\9.3\data\postgresql.conf'
(gc -path $conf ) | foreach-object{$_ -replace "timezone = 'US/Pacific'", "timezone = 'ETC/Universal'" } | set-content $conf
(gc -path $conf ) | foreach-object{$_ -replace "#max_prepared_transactions = 0", "max_prepared_transactions = 120" } | set-content $conf
start-service postgres*
write-host "Starting DB"
write-host "Adding DB Roles and Permissions"
if(!(Test-Path -Path $env:APPDATA\postgresql )){
   New-Item -ItemType directory -Path $env:APPDATA\postgresql\
}
$PGP="*:7336:postgres:postgres:$DBPASS"
$PGP | set-content $env:APPDATA\postgresql\pgpass.conf
$PBIN="c:\Program Files\Postgresql\9.3\bin\psql.exe"
& $PBIN -U postgres -p 7336 -f $INPATH\helpers\psql.sql postgres | out-null
write-host "Postgres install, roles, and settings complete"