$UserList = get-content \\D:\Users\alex.aranchuk\Desktop\Accounts.txt

Foreach ($Item in $UserList)
 {
$user = $null
$user =  Get-aduser -filter {samAccountName -eq $Item}
if ($user)
    {
    $user | Out-File D:\Users\alex.aranchukexistingAccounts.txt -encoding default -append
    }
    else
    {
    "$item does not exist" | Out-File D:\Users\alex.aranchuk\NotExistingAccounts.txt -encoding default -append
    }
}