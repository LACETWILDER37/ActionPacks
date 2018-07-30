#Requires -Version 5.1

<#
.SYNOPSIS
    Starts a async one-time backup operation

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Backup

.Parameter AllowDeleteOldBackups
    Indicates that the cmdlet deletes backups of older versions of the operating system

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [switch]$AllowDeleteOldBackups,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Properties = @("JobType","StartTime","EndTime","JobState","ErrorDescription")
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                $pol = Get-WBPolicy -ErrorAction Stop;
                Start-WBBackup -Policy $pol -Async -Force -AllowDeleteOldBackups:$Using:AllowDeleteOldBackups -ErrorAction Stop;
                Get-WBJob | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                $pol = Get-WBPolicy -ErrorAction Stop;
                Start-WBBackup -Policy $pol -Async -Force -AllowDeleteOldBackups:$Using:AllowDeleteOldBackups -ErrorAction Stop;
                Get-WBJob | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
    }
    else {
        $pol = Get-WBPolicy -ErrorAction Stop
        Start-WBBackup -Policy $pol -Async -Force -AllowDeleteOldBackups:$AllowDeleteOldBackups -ErrorAction Stop
        $Script:output = Get-WBJob | Select-Object $Properties
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}