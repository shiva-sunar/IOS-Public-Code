##################################################
# To create a csv file with Duplicate users, sorted with Last Login Date
$grouped = Import-Csv -Path .\Combined.csv | 
    ForEach-Object {if ([string]::IsNullOrWhiteSpace($_.LastLogon)) {$_.LastLogon = '1/1/1999 12:00:00 AM'}; $_} | 
    Sort-Object 'IOS-ID' | 
    Group-Object 'IOS-ID' | 
    Where-Object {$_.Count -gt 1}

$grouped | 
    ForEach-Object {
        $sortedGroup = $_.Group | Sort-Object {[datetime]::ParseExact($_.LastLogon, "M/d/yyyy h:mm:ss tt", $null)} -Descending
        $sortedGroup | ForEach-Object -Begin {$first = $true} {
            $_ | Add-Member -MemberType NoteProperty -Name "Enable" -Value $(if ($first) {"True"} else {"False"})
            $first = $false
            $_
        }
    } | 
    Export-Csv -Path .\output.csv -NoTypeInformation



###################################################################
# To Create the list of users to disable
cat output.csv | grep -v "OU=IT" | grep -v True | grep -i "DC=domainName,DC=local" | cut -d',' -f2 | sed "s/.*/&, /" | tr -d '\n'

###################################################################

# List of usernames to enable or disable the users.
$usersToEnable = @("user1", "User2")

foreach ($username in $usersToEnable) {
    try {
        # Find the user in AD
        $adUser = Get-ADUser -Identity $username -ErrorAction Stop

        # # Enable the user account
        # Enable-ADAccount -Identity $adUser -ErrorAction Stop
        # Write-Host "Enabled account for $username in $adUser.DistinguishedName"

        # Disable the user account
        Disable-ADAccount -Identity $adUser
        Write-Host "Disabled account for $username in $adUser.DistinguishedName"
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Host "User $username not found in Active Directory"
    }
    catch {
        Write-Host "An error occurred while enabling $username : $_"
    }
}

