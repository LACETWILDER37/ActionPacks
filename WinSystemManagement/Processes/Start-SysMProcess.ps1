#Requires -Version 4.0

<#
.SYNOPSIS
    Starts a process on the local computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Processes

.Parameter FilePath
    Specifies the path (optional) and file name of the program that runs in the process

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action

.Parameter ArgumentList
    Specifies parameters or parameter values to use when starting the process

.Parameter NoNewWindow
    Start the new process in the current console window, by default Windows PowerShell opens a new window.

.Parameter Verb
    Indicates that this cmdlet gets the file version information for the program that runs in the process.

.Parameter WindowStyle
    Specifies the state of the window that is used for the new process

.Parameter WorkingDirectory
    Specifies the location of the executable file or document that runs in the process
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$FilePath,
    [PSCredential]$AccessAccount,
    [string]$ArgumentList,
    [switch]$NoNewWindow,
    [Validateset("Edit", "Open", "Print", "Runas", "PrintTo", "Play")]
    [string]$Verb ,
    [Validateset("Normal","Hidden","Minimized","Maximized")]
    [string]$WindowStyle = "Normal",
    [string]$WorkingDirectory
)

try{
    [string[]]$Properties = @("Name","ID","FileVersion","UserName","PagedMemorySize","PrivateMemorySize","VirtualMemorySize","TotalProcessorTime","Path","CPU","StartTime")
    $Script:output

    if([System.String]::IsNullOrWhiteSpace($ArgumentList) -eq $true){
        $ArgumentList = " "
    }
    if([System.String]::IsNullOrWhiteSpace($WorkingDirectory) -eq $true){
        $WorkingDirectory = " "
    }
    
    if([System.String]::IsNullOrWhiteSpace($Verb) -eq $true){
        if($null -eq $AccessAccount){
            if($NoNewWindow -eq $false){
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList `
                    -WorkingDirectory $WorkingDirectory -WindowStyle $WindowStyle -PassThru -ErrorAction Stop
            }
            else {
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList `
                    -WorkingDirectory $WorkingDirectory -NoNewWindow -PassThru -ErrorAction Stop
            }
        }
        else {
            if($NoNewWindow -eq $false){
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -Credential $AccessAccount `
                    -WorkingDirectory $WorkingDirectory -WindowStyle $WindowStyle -PassThru -ErrorAction Stop
            }
            else {
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -Credential $AccessAccount `
                    -WorkingDirectory $WorkingDirectory -NoNewWindow -PassThru -ErrorAction Stop
            }
        }
    }
    else {
        if($null -eq $AccessAccount){
            if($NoNewWindow -eq $false){
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -Verb $Verb `
                    -WorkingDirectory $WorkingDirectory -WindowStyle $WindowStyle -PassThru -ErrorAction Stop
            }
            else {
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -Verb $Verb `
                    -WorkingDirectory $WorkingDirectory -NoNewWindow -PassThru -ErrorAction Stop
            }
        }
        else {
            if($NoNewWindow -eq $false){
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -Verb $Verb -Credential $AccessAccount `
                    -WorkingDirectory $WorkingDirectory -WindowStyle $WindowStyle -PassThru -ErrorAction Stop
            }
            else {
                $Script:process = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -Verb $Verb -Credential $AccessAccount `
                    -WorkingDirectory $WorkingDirectory -NoNewWindow -PassThru -ErrorAction Stop
            }
        }
    }
    $Script:output = Get-Process -ID $Script:process.ID -IncludeUserName | Select-Object $Properties

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