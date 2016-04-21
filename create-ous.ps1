# get:
#      Computer Name
#      Domain Name
#      Location
# can be replaced with:
#                      FQDN
#                           (contains) Computer Name,Domain Name, Location = DC=[Domain Name],OU=[Part of Domain]
$computername = read-host "please enter computername"
$domainname = read-host "please enter domain name"
$location = read-host "where to create ous"
# save:
#      Group Name in a Variable
$groupname = "Branch Admin"

Import-Module -Name ActiveDirectory

# RegEx: \w
#           w means any character (upper or lower case) any number and underline_ and character with accent (like french)
#             but not unicode character.
$computername -match "(\w+)-inta";$ouname = $Matches[1]

New-ADOrganizationalUnit -Path "$location" -Name "$ouname"

$theou = "OU=$ouname,"+"$location"

New-ADOrganizationalUnit -Path "$theou" -Name "Users"
New-ADOrganizationalUnit -Path "$theou" -Name "Groups"
New-ADOrganizationalUnit -Path "$theou" -Name "Computers"

New-ADUser  -Path "OU=Users,$theou" `
            -Name $ouname -SamAccountName $ouname `
            -PasswordNeverExpires $true `
            -AccountPassword (ConvertTo-SecureString -AsPlainText "123" -Force) `
            -DisplayName $ouname `
            -Enabled $true `
            -GivenName $ouname `
            -UserPrincipalName "$ouname@$domainname"


Add-ADGroupMember -Identity $groupname -Members $ouname