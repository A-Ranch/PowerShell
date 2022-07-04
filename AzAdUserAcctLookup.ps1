$UserList = Get-Content C:\Users\twinz\Desktop\Accounts.txt
  
ForEach ($Item in $UserList)
{
    $user = $null
    $user = Get-AzADUser| Where-Object {$_.DisplayName -eq $Item}
if ($user)
	    {
		$user | Out-File C:\Users\twinz\Desktop\existingAccounts.txt -encoding default -append
	    }
	else
	    {
			"$item does not exist" | Out-File C:\Users\twinz\Desktop\NotExistingAccount.txt -encoding default -append
		}
}
