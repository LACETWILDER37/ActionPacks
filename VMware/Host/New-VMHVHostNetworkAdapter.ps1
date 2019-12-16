#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

<#
.SYNOPSIS
    Creates a new HostVirtualNIC (Service Console or VMKernel) on the specified host

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter HostName
    Specifies the name of the host whose network adapter you want to add

.Parameter SwitchName
    Specifies the name of the virtual switch to which you want to add the new network adapter

.Parameter PortGroup
    Specifies the port group to which you want to add the new adapter

.Parameter AutomaticIPv6
    Indicates that the IPv6 address is obtained through a router advertisement

.Parameter ConsoleNic
    If the value is $true, indicates that you want to create a service console virtual network adapter

.Parameter Dhcp
    Indicates whether the host network adapter uses a Dhcp server

.Parameter FaultToleranceLoggingEnabled
    Indicates that the network adapter is enabled for Fault Tolerance (FT) logging

.Parameter IPv4
    Specifies an IP address for the network adapter using an IPv4 dot notation

.Parameter IPv6
    Specifies an IPv6 address for the network adapter

.Parameter IPv6ThroughDhcp
    Indicates that the IPv6 address is obtained through DHCP

.Parameter IPv6Enabled
    Indicates that IPv6 configuration is enabled

.Parameter MACAddress
    Specifies the media access control (MAC) address of the virtual network adapter

.Parameter ManagementTrafficEnabled
    Indicates that you want to enable the network adapter for management traffic

.Parameter MtuSize
    Specifies the MTU size

.Parameter SubnetMask
    Specifies a subnet mask for the NIC

.Parameter VMotionEnabled
    Indicates that you want to use the virtual host/VMKernel network adapter for VMotion

.Parameter VsanTrafficEnabled
    Specifies whether Virtual SAN traffic is enabled on this network adapter
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$HostName,
    [Parameter(Mandatory = $true)]
    [string]$SwitchName,
    [Parameter(Mandatory = $true)]
    [string]$PortGroup,
    [bool]$AutomaticIPv6,
    [switch]$Dhcp,
    [bool]$FaultToleranceLoggingEnabled,
    [string]$IPv4,
    [string]$IPv6,
    [bool]$IPv6Enabled,
    [bool]$IPv6ThroughDhcp,
    [string]$MACAddress,
    [bool]$ManagementTrafficEnabled,
    [int32]$MtuSize,
    [string]$SubnetMask,
    [bool]$VMotionEnabled,
    [bool]$VsanTrafficEnabled,
    [switch]$ConsoleNic
)

Import-Module VMware.PowerCLI

try{  
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    
    $vmHost = Get-VMHost -Server $Script:vmServer -Name $HostName -ErrorAction Stop
    $vSwitch = Get-VirtualSwitch -VMHost $vmHost -Name $SwitchName -ErrorAction Stop   
    $vAdapter = New-VMHostNetworkAdapter -VMHost $vmHost -VirtualSwitch $vSwitch -ConsoleNic:$ConsoleNic -AutomaticIPv6:$AutomaticIPv6 `
                            -PortGroup $PortGroup -IPv6ThroughDhcp:$IPv6ThroughDhcp -Confirm:$false -ErrorAction Stop
         
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'VirtualNic' = $Script:vAdapter
                            'Confirm' = $false    
                            }                            
    if($PSBoundParameters.ContainsKey('Dhcp') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -Dhcp:$Dhcp -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('FaultToleranceLoggingEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -FaultToleranceLoggingEnabled $FaultToleranceLoggingEnabled -Confirm:$false -ErrorAction Stop | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv4') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IP $IPv4 | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv6') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IPv6 $IPv6 | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv6ThroughDhcp') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IPv6ThroughDhcp $IPv6ThroughDhcp | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('MACAddress') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -MAC $MACAddress | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('ManagementTrafficEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -ManagementTrafficEnabled $ManagementTrafficEnabled | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('MtuSize') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -Mtu $MtuSize | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('SubnetMask') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -SubnetMask $SubnetMask | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VMotionEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -VMotionEnabled $VMotionEnabled | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('VsanTrafficEnabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -VsanTrafficEnabled $VsanTrafficEnabled | Select-Object *
    }
    if($PSBoundParameters.ContainsKey('IPv6Enabled') -eq $true){
        $Script:Output = Set-VMHostNetworkAdapter @cmdArgs -IPv6Enabled $IPv6Enabled | Select-Object *
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output 
    }
    else{
        Write-Output $Script:Output
    }
}
catch{
    throw
}
finally{    
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}