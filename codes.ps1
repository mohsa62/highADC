(get-adcomputer -filter * -pro distinguishedname,operatingsystem |
    where {$_.operatingsystem -notlike "*Windows 7*"} |
    %{Test-Connection -ComputerName $_.name -Count 1}).count

(get-adcomputer -filter * -pro distinguishedname,operatingsystem,ipv4address |
    %{Test-Connection -ComputerName $_.name -Count 1 -ErrorAction SilentlyContinue}).count

(Get-WmiObject -Class win32_quickfixengineering | ?{$_.description -eq "Security Update"}).count

(Get-WmiObject -Class win32_quickfixengineering | ?{$_.description -eq "Service Pack"}).count
if (Get-WmiObject -Class win32_quickfixengineering | ?{$_.description -eq "Service Packsf"}) {Write-Host -Object "test"}

Get-EventLog -LogName security -message *S-1-5-21-3763905205-4108663294-210956779-1119* | 
    ?{$_.eventid -eq "4624"} | %{select -Property message -ExpandProperty message -InputObject $_}
