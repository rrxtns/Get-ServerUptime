<#
.SYNOPSIS
Calculates uptime for the specified computer(s).

.NOTES
File Name   : Get-ServerUptime.ps1 
Author      : rrxtns@users.noreply.github.com
Requires    : PowerShell Version 2.0, Windows 2008 or greater 

.DESCRIPTION
This function uses the Win32_OperatingSystem class to retrieve the
LastBootUpTime, and calculate uptime based on the local system time.

.PARAMETER ComputerName
The name or IP address of the computer to calculate uptime for.
         
.EXAMPLE
Get-ServerUptime -ComputerName SERVER01
         
Displays uptime for the computer named "SERVER01"
 
.EXAMPLE 
Get-Content c:\names.txt | Get-ServerUptime.ps1

Read computer names from a file (one name per line) and retrieve their uptime information.
   
#>
Param([Parameter(Mandatory = $True,
	ValueFromPipeLine = $True,
	Position = 0)]
	[Alias('')]
	[String]$ComputerName = "localhost"
	)
BEGIN {
	# Set to Continue for debugging
	$ErrorActionPreference = "SilentlyContinue";

	#Init an array
	$jobList = @(); 
}
PROCESS {
	$jobList += Invoke-Command -ComputerName $ComputerName -ScriptBlock { 
		$LastBoot = (Get-WmiObject -Class Win32_OperatingSystem).LastBootUpTime;
		$SysUptime = (Get-Date) – [System.Management.ManagementDateTimeconverter]::ToDateTime($LastBoot);
		$Server = $ENV:ComputerName;
		$objReturn = New-Object PSobject;
		$objReturn | Add-Member -MemberType Noteproperty -Name ServerName -value $Server;
		$objReturn | Add-Member -MemberType Noteproperty -Name Days -value $SysUpTime.Days;
		$objReturn | Add-Member -MemberType Noteproperty -Name Hours -value $SysUpTime.Hours;
		$objReturn | Add-Member -MemberType Noteproperty -Name Minutes -value $SysUpTime.Minutes;
		$objReturn | Add-Member -MemberType Noteproperty -Name Seconds -value $SysUpTime.Seconds;
		$objReturn;
	} -AsJob;
}
END {
	$results = $jobList | Wait-Job | Receive-Job -ErrorAction SilentlyContinue;
	$results | Select * -excludeproperty PSComputerName,RunspaceId,PSShowComputerName;
}