#
Get-AzSubscription
Select-AzSubscription -SubscriptionName {string}
#

$UserList = Get-Content C:\Users\aaranchu\Documents\WindowsPowershell\Accounts.txt  

ForEach ($Item in $UserList)
{
    $user = $null
    $user = Get-AzADUser| Where-Object {$_.DisplayName -eq $Item}
if ($user)
	    {
		$user | Out-File C:\Users\aaranchu\Desktop\existingAccounts.txt -encoding default -append
	    }
	else
	    {
			"$item does not exist" | Out-File C:|Users\aaranchu\Desktop\NotExistingAccount.txt -encoding default -append
		}
}
