# bginfo
$INPATH='\\remin\shares\psql'
write-host "Setup BGINFO"
if(!(Test-Path -Path c:\bginfo )){
   New-Item -ItemType directory -Path c:\bginfo
}
copy-item -path $INPATH\apps\bginfo\*.* c:\bginfo\
copy-item -path $INPATH\apps\psBGinfo\*.* c:\bginfo\
& c:\bginfo\PSBgInfo.ps1 -Config "W2012"
