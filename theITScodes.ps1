$computername = read-host "please enter computername"
$domainname = read-host "please enter domain name"
Rename-Computer -ComputerName $env:COMPUTERNAME -NewName $computername
$localdns = Read-Host "Please enter local dns ip address"

Get-WmiObject win32_networkadapterconfiguration -filter "ipenabled = 'true'" | 
    fl -Property IPAddress,IPSubnet,DefaultIPGateway,DNSServerSearchOrder

Get-WmiObject win32_networkadapterconfiguration | 
    fl Description,IPAddress,DNSDomain,ServiceName,ipenabled

Get-WmiObject win32_networkadapterconfiguration | 
    ft Description,IPAddress,DNSDomain,ServiceName,ipenabled -AutoSize

$UnbindID = $(Get-WmiObject -Class 'Win32_NetworkAdapter' | Where-Object {$_.NetConnectionID -eq 'Local Area Connection'}).GUID
$LinkageKey = $(Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\Tcpip6\Linkage').Bind | Select-String -Pattern $UnbindID -NotMatch -SimpleMatch
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\services\Tcpip6\Linkage' -Name 'Bind' -Type MultiString -Value $LinkageKey

$location = read-host "where to create ous"

$computername -match "(\w+)-inta";$ouname = $Matches[1]

New-ADOrganizationalUnit -Path "$location" -Name "$ouname"

$theou = "OU=$ouname,"+"$location"

New-ADOrganizationalUnit -Path "$theou" -Name "Users"
New-ADOrganizationalUnit -Path "$theou" -Name "Groups"
New-ADOrganizationalUnit -Path "$theou" -Name "Computers"

New-ADUser -Path "OU=Users,$theou" -Name $ouname -SamAccountName $ouname -PasswordNeverExpires $true -AccountPassword (ConvertTo-SecureString -AsPlainText "123" -Force) -DisplayName $ouname -Enabled $true -GivenName $ouname -UserPrincipalName "$ouname@khoozestan-its.gov"

new-gpo -Name "Izeh1"
new-gpo -Name "Izeh2"
new-gpo -Name "Izeh3" -Server "Izeh-INTA.Khoozestan-its.gov"

New-GPLink -Name "Izeh1" -Target $theou
New-GPLink -Name "Izeh2" -Target $theou
New-GPLink -Name "Izeh3" -Target $theou

Set-GPPermissions -Name Izeh1 -TargetName "Izeh@khoozestan-its.gov" -TargetType User -PermissionLevel GpoEdit
Set-GPPermissions -Name $ouname"2" -TargetName $ouname"@"$domainname -TargetType User -PermissionLevel GpoEdit
Set-GPPermissions -Name $ouname"3" -TargetName $ouname"@"$domainname -TargetType User -PermissionLevel GpoEdit


"10.140.1.133 `t`t inta-root.inta-its.gov"                                   | Out-File -FilePath $env:SystemRoot\System32\drivers\etc\hosts -Append -Encoding default
"10.140.1.133 `t`t 25738580-4522-4890-b55c-5408eb4d4c79._msdcs.inta-its.gov" | Out-File -FilePath $env:SystemRoot\System32\drivers\etc\hosts -Append -Encoding default
"10.140.1.132 `t`t inta-its-bkp.inta-its.gov"                                | Out-File -FilePath $env:SystemRoot\System32\drivers\etc\hosts -Append -Encoding default
"10.140.1.132 `t`t ffa13d1a-1eb2-4691-bd38-51f75d718866._msdcs.inta-its.gov" | Out-File -FilePath $env:SystemRoot\System32\drivers\etc\hosts -Append -Encoding default

# dnscmd /zoneadd $localdnssrv /dsforwarder $localdnsip # this is active directory integrated
dnscmd /zoneadd $localdnssrv /forwarder $localdnsip # this is not active directory integrated


dnscmd ahwaz-inta.khoozestan-its.gov /zoneinfo tax1600.org