<#
	.SYNOPSIS
		Generates random passphrases or passwords in a flexible way
	
	.NOTES
		Script Name:	Get-RandomPassword.ps1
		Created By:		Gavin Townsend
		Date:			October 2019
		
	.DESCRIPTION
		The script performs the follow actions:
			- Selects random words from a dictionary file
			- Ensures to get a character selection from all four character sets
			- Builds password using custom patterns depending on use cases
			
		
	.EXAMPLE
			.\Get-RandomPassword.ps1
			
			
	.REQUIREMENTS
		1. Populate a dictionary word list
		
			Example (3700+ words) https://help.ubuntu.com/community/StrongPasswords?action=AttachFile&do=view&target=word-list.txt
		
		
	.VERSION HISTORY
		1.0		Oct 2019	Gavin Townsend		Original Build

#>

#VARIABLES
#---------
$Dict = ".\dict.txt"

[string]$sChars1 = $NULL
[string]$sChars2 = $NULL
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

#Import random words from dictionary (optionally apply TitleCase)
Function TitleCase{
	Param ([string]$Word)
	(Get-Culture).TextInfo.ToTitleCase($Word)
}

$Words = Get-Content $Dict | sort{Get-Random} | select -First 5
$Word1 = $Words[0]		# $Word1 = TitleCase $Words[0]
$Word2 = $Words[1]		# $Word2 = TitleCase $Words[1]
$Word3 = $Words[2]		# $Word3 = TitleCase $Words[2]
$Word4 = $Words[3]		# $Word4 = TitleCase $Words[3]
$Word5 = $Words[4]		# $Word5 = TitleCase $Words[4]

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


#GENERATE
#--------

#Build password (modify pattern for usability and strength as desired)
$Password1 = $Word1 + $Special1 + $sChars1
$Password2 = $Word1 + $Special1 + $Word2 + $Special2 + $sChars1
$Password3 = $Word1 + "-" + $Word2 + "-" + $Word3 + "-" + $sChars1 + $Special1
$Password4 = $Word1 + $Word2 + $Word3 + $Word4 + $Word5
$Password5 = $sChars2

$Password1
$Password2
$Password3
$Password4
$Password5


#Apply password to AD user
#Set-ADAccountPassword john.doe -NewPassword $Password3 -Reset -PassThru | Set-ADuser -ChangePasswordAtLogon $True
