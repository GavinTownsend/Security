<#
	.SYNOPSIS
		Generates random passphrases or passwords in a flexible way
	
	.NOTES
		Script Name:	Get-PW.ps1
		Created By:	Gavin Townsend
		Date:		October 2019
		
	.DESCRIPTION
		The script performs the follow actions:
			- Selects random words from a dictionary file
			- Ensures to get a character selection from all four character sets
			- Builds password using custom patterns depending on use cases	
		
	.EXAMPLE
		>Get-PW
			
			
	.REQUIREMENTS
		1. Populate a dictionary word list
		
			Example (3700+ words) https://help.ubuntu.com/community/StrongPasswords?action=AttachFile&do=view&target=word-list.txt
		
		Optionally add functions to local profile (C:\Windows\System32\WindowsPowerShell\v1.0\profile.ps1)
		
		
	.VERSION HISTORY
		1.0		Oct 2019	Gavin Townsend		Original Build
		1.1		Oct 2019	Gavin Townsend		Created functions for adding to local PS profile
		1.2		Jul	2020	Gavin Townsend		Added phrase generator from your own sentence

#>


Function get-pw{
	
	#VARIABLES
	#---------
	
	$Dict = ".\dict.txt"

	[string]$sChars1 = $NULL
	[string]$sChars2 = $NULL
	$MySentence = Read-Host 'Write a sentence to create your own phrase (or hit enter to skip)'
	$Words = @()
	$Chars1 = @()
	$Chars2 = @()
	$Lower1 = @()
	$Lower2 = @()
	$Upper1 = @()
	$Upper2 = @()
	$Number1 = @()
	$Number2 = @()
	$Special1 = @()
	$Special2 = @()
	$Special3 = @()

	If (Test-Path $Dict) {
		$Words = Get-Content $Dict | sort{Get-Random} | select -First 5
		$Word1 = $Words[0]
		$Word2 = $Words[1]
		$Word3 = $Words[2]
		$Word4 = $Words[3]
		$Word5 = $Words[4]
	}
	Else {
		Write-Host "WARNING: Dictionary file unavailable - words are not random" -foregroundcolor red
		$Word1 = "Apple"
		$Word2 = "Magpie"
		$Word3 = "Articulate"
		$Word4 = "Sanction"
		$Word5 = "Indeed"
	}
	
	#Define Character Sets
	$sLowercase = [char[]](97..122)
	$sUpercase = [char[]](65..90)
	$sNumbers = [char[]](48..57)
	$sSpecial = [char[]](33..47) + [char[]](58..64) + [char[]](91..96) + [char[]](123..126)


	#DEFINE PASSPHRASES
	#------------------

	#Define the number of characters for each set and import into arrays
	1..2 | ForEach {$Lower1 += ($sLowercase | Get-Random)}
	1..2 | ForEach {$Upper1 += ($sUpercase | Get-Random)}
	1..1 | ForEach {$Number1 += ($sNumbers | Get-Random)}

	#Define Seperators (can also be used in $Chars1)
	1..1 | ForEach {$Special1 += ($sSpecial | Get-Random)}
	1..1 | ForEach {$Special2 += ($sSpecial | Get-Random)}

	#Join arrays, convert into a string and randomise again
	$Chars1 = $Lower1 + $Upper1 + $Number1  # + $Special1
	$sChars1 = $Chars1 | Sort-Object {Get-Random}
	$sChars1 = $sChars1.Replace(' ', '')

	#DEFINE RANDOM STRING
	#--------------------

	#Define Large Random set
	1..8 | ForEach {$Lower2 += ($sLowercase | Get-Random)}
	1..8 | ForEach {$Upper2 += ($sUpercase | Get-Random)}
	1..8 | ForEach {$Number2 += ($sNumbers | Get-Random)}
	1..8 | ForEach {$Special3 += ($sSpecial | Get-Random)}

	#Join arrays, convert into a string and randomise again
	$Chars2 = $Lower2 + $Upper2 + $Number2 + $Special3
	$sChars2 = $Chars2 | Sort-Object {Get-Random}
	$sChars2 = $sChars2.Replace(' ', '')

	#DEFINE MY SENTENCE
	#------------------
	
	if ($MySentence.length -gt 1) {
		$MyWords = $MySentence.split(" ")
		foreach ($MyWord in $MyWords){
			$MyPhrase+=$MyWord.ToCharArray() | Select-Object -First 1
		}
	}

	#GENERATE
	#--------

	#Build password (modify pattern for usability and strength as desired)
	$Password1 = $Word1 + $Special1 + $sChars1
	$Password2 = $Word1 + $Special1 + $Word2 + $Special2 + $sChars1
	$Password3 = $Word1 + "-" + $Word2 + "-" + $Word3 + "-" + $sChars1 + $Special1
	$Password4 = $Word1 + $Word2 + $Word3 + $Word4 + $Word5
	$Password5 = $sChars2
	if ($MySentence.length -gt 1) {
		$Password6 = $MyPhrase+ "-" +$sChars1
	}

	#DISPLAY and CLIP
	#----------------

	write-host " "
	write-host $Password1
	write-host $Password2
	write-host $Password3 -foregroundcolor yellow
	write-host $Password4
	write-host $Password5
	if ($MySentence.length -gt 1) {
		write-host $Password6
	}
	write-host " "

	try{
		$Password3 | Out-String -stream | Set-Clipboard
	}
	Catch{
		$Password3 | clip
	}
}


Function set-pw{
	Param (	[string]$Username,
		[string]$PW)
			
	Set-ADAccountPassword $Username -NewPassword $PW -Reset -PassThru | Set-ADuser -ChangePasswordAtLogon $True
}


get-pw
