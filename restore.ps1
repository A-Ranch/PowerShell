<#Alex Aranchuk 001837221
Task 2 c916 
.SYNOPSIS
  This script restores active directory OU's and reconfigures SQL server.
.DESCRIPTION
  Write a single script within the “restore.ps1” file that performs all of the following functions without user interaction:
  1.  Create an Active Directory organizational unit (OU) named “finance.”
  2.  Import the financePersonnel.csv file (found in the “Requirements2” directory) into your Active Directory domain and directly into the finance OU. Be sure to include the following properties:
  •  First Name
  •  Last Name
  •  Display Name (First Name + Last Name, including a space between)
  •  Postal Code
  •  Office Phone
  •  Mobile Phone
  3.  Create a new database on the SQL server called “ClientDB.”
  4.  Create a new table and name it “Client_A_Contacts.” Add this table to your new database.
  5.  Insert the data from the attached “NewClientData.csv” file (found in the “Requirements2” folder) into the table created in part B5.
 
#>

Try 
{

Write-Host -ForegroundColor Green " [AD]: Starting Active Directory Tasks"
#Create AD OU
$ADRoot = "DC=consultingfirm, DC=com"
$OUCanonicalName = "finance"
$OUDisplayName = "finance"
New-ADOrganizationalUnit -Path $ADRoot -Name $OUCanonicalName -DisplayName $OUDisplayName -ProtectedFromAccidentalDeletion $false

Write-Host -ForegroundColor Green " [AD]: $($OUCanonicalName) OU Created"
#Import CSV File contaning user profiles
$NewAD = Import-Csv $PSScriptRoot\financePersonnel.csv

$Path = "OU=finance, DC=consultingfirm, DC=com"

#Iterate over each row in the table
ForEach ($ADuser in $NewAD)

{
#Assign variables to column values
   $First = $ADuser.First_Name

   $Last = $ADuser.Last_Name

   $Name = $First + " " + $Last

   $SamName = $AdUser.samAccount

   $Postal = $ADuser.PostalCode

   $Office = $ADuser.OfficePhone

   $Mobile = $ADuser.MobilePhone
   
#Use variables to create each user
  New-ADUser -GivenName $First `
             -Surname $Last `
			 -Name $Name `
			 -SamAccountName $SamName `
			 -DisplayName $Name `
			 -PostalCode $Postal `
			 -MobilePhone $Mobile `
			 -OfficePhone $Office `
			 -Path $Path 
} 

#Import SQL Server Module
Import-Module -Name SQLserver 
#Set a string variable equal to the Name of the Server Instance
$sqiServName = "SRV19-PRIMARY\SQLEXPRESS"
#Create an object reference to the Server Instance
$sqiServ = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Server -ArgumentList $sqiServName
#Set a string variable equal to the name of the Database
$DB_Name = "ClientDB"
#Create an object reference to the database
$DB = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $sqiServName, $DB_Name  
#Call the Create method on the database object to create it
$DB.Create()
  
  Write-Host -ForegroundColor Green "[SQL]: Database Created"

#Execute T-SQL code against the database 
Invoke-Sqlcmd -ServerInstance $sqiServName -Database $DB_Name -InputFile $PSScriptRoot\CreateTable_Client_A_Contacts.sql
 
 #Set a string variable equal to the Name of the table
 $tableName = 'Client_A_Contacts' 
 $Insert = "INSERT INTO [$($tableName)] (first_name, last_name, city, county, zip, officePhone, mobilePhone) "
 $NewClientData = Import-Csv $PSScriptRoot\NewClientData.csv
 
 #Iterate over each row in the table
 ForEach($NewClient in $NewClientData)
 {
	 #Format the Values portion of the INSERT INTO statement
	 $Values = "VALUES ( `
	                 '$($NewClient.first_name)',`
					 '$($NewClient.last_name)',`
					 '$($NewClient.city)',`
					 '$($NewClient.county)',`
					 '$($NewClient.zip)',`
					 '$($NewClient.officePhone)',`
					 '$($NewClient.mobilePhone)')"
	$query = $Insert + $Values		
	#Run code against the database
	Invoke-Sqlcmd -Database $DB_Name -ServerInstance $sqiServName -Query $query
 }
 Write-Host -ForegroundColor Green "[SQL]: Table Created"
}
 
catch [System.OutOfMemoryException]
{ 
    Write-Host -ForgeoundColor Magenta "An Error has occurred!"
}