<#Alex Aranchuk 001837221
  task 1 c916
 .SYNOPSYS
 Create a PowerShell script named “prompts.ps1” within the “Requirements1” folder.
 Create a “switch” statement that continues to prompt a user by doing each of the following activities, until a user presses key 5:

1.  List files within the Requirements1 folder, with the .log file extension and redirect the results to a new file called “DailyLog.txt” within the same directory without overwriting existing data. Each time the user selects this prompt, the current date should precede the listing. (User presses key 1.)

2.  List the files inside the “Requirements1” folder in tabular format, sorted in ascending alphabetical order. Direct the output into a new file called “C916contents.txt” found in your “Requirements1” folder. (User presses key 2.)

3.  List the current CPU and memory usage. (User presses key 3.)

4.  List all the different running processes inside your system. Sort the output by virtual size used least to greatest, and display it in grid format. (User presses key 4.)

5.  Exit the script execution. (User presses key 5.)
#>


   Try 
{      
  ## Creating a while loop, user input options menu.
	while ( $n -ne 5)
	{
		write-host -ForegroundColor Green '1. List log files within the Requirements1 folder.
2. List the files inside the Requirements1 folder.
3. List the current CPU and memory usage. 
	
4. Display running processes.
		
5. Exit the script execution.
'
		$n = Read-Host -Prompt '>> Select a Number'
		## “switch” statement that continues to prompt a user by doing each of the following activities, 
		## until a user presses key 5
		switch -Exact ($n)
		{
			1 {
			## Using a regular expression, list files within the Requirements1 folder, with the .log file extension	
			## and redirect the results to a new file called “DailyLog.txt” within the same directory without overwriting existing data.
			## Each time the user selects this prompt, the current date should precede the listing 
			Get-Date | Out-File -Append -FilePath .\DailyLog.txt
			Get-ChildItem $PSScriptRoot | Where-Object name -like *.log | Out-File -Append -FilePath .\DailyLog.txt
               } 
			2 {
				##List the files inside the “Requirements1” folder in tabular format, sorted in ascending alphabetical order. 
			   ##Direct the output into a new file called “C916contents.txt” found in your “Requirements1” folder. 
				Get-ChildItem $PSScriptRoot | Sort-Object Name | Format-Table | Out-File .\C916contents.txt	
				}
			3 { ##  List the current CPU and memory usage.
				Get-Counter -Counter "\Processor(_Total)\% Processor Time" 
                Get-Counter -Counter "\Memory\Committed Bytes"
				}
			4 { ## List all the different running processes inside your system sortedby virtual size.
				Get-Process | Select-Object Name, ID, TotalProcessorTime | Sort-Object TotalProcessorTime | Format-Table
				}
			5 {
				##   Exit the script execution
			}
		}
	}
}
Catch [System.OutOfMemoryException] 
{
	Write-Host -ForegroundColor Magenta "An Error Occured!"
}