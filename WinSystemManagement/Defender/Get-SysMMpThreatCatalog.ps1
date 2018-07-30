#Requires -Version 4.0

<#
.SYNOPSIS
    Gets known threats from the definitions catalog

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Defender

.Parameter ThreatID
    Specifies the threat ID

.Parameter ItemCount
    Limit the number of the last threats

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [int64]$ThreatID,
    [int]$ItemCount = 25,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($ThreatID -gt 0){
        $threat = Get-MpThreatCatalog -CimSession $Script:Cim -ThreatID $ThreatID -ErrorAction Stop
    }
    else {
        $threat = Get-MpThreatCatalog -CimSession $Script:Cim -ErrorAction Stop | Select-Object -Last $ItemCount
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $threat
    }
    else{
        Write-Output $threat
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}