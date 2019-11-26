<#
	.SYNOPSIS
		Central logging of Azure Password Protection (APP) event logs
	
	.NOTES
		Script Name:	get-AzurePasswordProtectionReport.ps1
		Created By: 	Gavin Townsend
		Date:    November 2019
	
	.DESCRIPTION
		- Identifies Domain Controllers that have the APP agent installed
		- Queries the local event logs on DC's for specific APP events
		- Summarises events to a central csv log
		- A new log file is created each month and will update each time the script runs
		
	.EXAMPLE
		.\get-AzurePasswordProtectionReport.ps1
		
		Scheduled Task - Action 'Start a Program'
			Program: 	C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
			Arguments:	-NonInteractive C:\Scripts\get-AzurePasswordProtectionReport.ps1
			Start in:	C:\Scripts\

	.REQUIREMENTS
		Azure Password Protection Proxy Agent installation (has the new PowerShell cmdlets)
		Access to read local DC event logs  (most likely domain admin role)
		
	.VERSION HISTORY
		1.0		November 2019	Gavin Townsend		Original Build
		
#>

$Log = "\\server01\logs$\APP\Azure Password Protection Log $(get-date -f yyyy-MM).csv"
$OutData = @()
$Servers = @(Get-AzureADPasswordProtectionDCAgent).ServerFQDN 

$Filter = @{
	Logname = 'Microsoft-AzureADPasswordProtection-DCAgent/Admin'
	ID = 10014,10015,30002,30003,30004,30005,30007,30008,30009,30010,30026,30027,30028,30029
	StartTime =  [datetime]::Today.AddDays(-31)
}

ForEach ($Server in $Servers) {
	Try{
		$Events = Get-WinEvent -ComputerName $Server -FilterHashtable $Filter -ErrorAction SilentlyContinue
		
		ForEach ($Event in $Events) {
		
			switch($Event.ID){
				10014{$Summary = "Accepted"}
				10015{$Summary = "Accepted"}
				30002{$Summary = "Rejected - Custom Blocklist"}
				30003{$Summary = "Rejected - Custom Blocklist"}
				30004{$Summary = "Rejected - Microsoft Blocklist"}
				30005{$Summary = "Rejected - Microsoft Blocklist"}
				30007{$Summary = "Audit Fail Only - Custom Blocklist"}
				30008{$Summary = "Audit Fail Only - Custom Blocklist"}
				30009{$Summary = "Audit Fail Only - Microsoft Blocklist"}
				30010{$Summary = "Audit Fail Only - Microsoft Blocklist"}
				30026{$Summary = "Rejected - Microsoft & Custom Blocklists"}
				30027{$Summary = "Rejected - Microsoft & Custom Blocklists"}
				30028{$Summary = "Audit Fail Only - Microsoft & Custom Blocklist"}
				30029{$Summary = "Audit Fail Only - Microsoft & Custom Blocklist"}
				default {$Summary = "Unknown"}
			}
			
			$eventXML = [xml]$Event.ToXml()
			$Username = $eventXML.Event.EventData.Data[0].'#text'
	
			$obj = New-Object PSobject
			$obj | Add-Member NoteProperty -Name "Time" -Value $Event.TimeCreated
			$obj | Add-Member NoteProperty -Name "Server" -Value $Server
			$obj | Add-Member NoteProperty -Name "ID" -Value $Event.ID
			$obj | Add-Member NoteProperty -Name "Username" -Value $Username
			$obj | Add-Member NoteProperty -Name "Summary" -Value $Summary
			$obj | Add-Member NoteProperty -Name "Message" -Value $Event.Message

			$OutData += $obj
		}
		
	}
	Catch{
		Write-Host "Unable to access $Server" -foregroundcolor yellow
	}
}

$OutData = $OutData | sort -Property "Time" -descending
$OutData | Export-CSV $Log -notype

<#

Test with

New-ADUser -Name "Test Bad Password" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -DisplayName "Test Bad Password" -Enabled $False -SamAccountName "Test.PW" -Server "SRV-DC01" 


#>
