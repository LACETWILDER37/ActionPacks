#Requires -Version 5.1

<#
.SYNOPSIS
    Gets the current backup operation

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

.Parameter Previous
    Specifies the number of previous backup operations for which the server queries the event manager

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. JobType,JobState. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [uint32]$Previous,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [string]$Properties = "JobType,StartTime,EndTime,JobState,ErrorDescription"
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($Properties) -eq $true){
        $Properties = "*"
    }
    [string[]]$Script:props = $Properties.Split(',')
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            if($Previous -gt 0){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    Get-WBJob -Previous $Using:Previous | Select-Object $Using:props
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                     Get-WBJob | Select-Object $Using:props
                } -ErrorAction Stop
            }
        }
        else {
            if($Previous -gt 0){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-WBJob -Previous $Using:Previous | Select-Object $Using:props
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-WBJob | Select-Object $Using:props
                } -ErrorAction Stop
            }
        }
    }
    else {
        if($Previous -gt 0){
            $Script:output = Get-WBJob -Previous $Previous | Select-Object $Script:props
        }
        else {
            $Script:output = Get-WBJob | Select-Object $Script:props
        }
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