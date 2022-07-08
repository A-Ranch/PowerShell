#
Get-AzSubscription
Select-AzSubscription -SubscriptionName [string]
 Connect-AzAccount -TenantId [string] #OPS
 
$Path=[string]
#

$UserList = Get-Content $Path.\Accounts.txt 

ForEach ($Item in $UserList)
{
    $user = $null
    $user = Get-AzADUser| Where-Object {$_.DisplayName -eq $Item}
if ($user)
	    {
		$user | Out-File $Path\existingAccounts.txt -encoding default -append
	    }
	else
	    {
			"$item does not exist" | Out-File $Path\NotExistingAccount.txt -encoding default -append
		}
}
