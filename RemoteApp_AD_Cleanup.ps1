param ( 
 # Mandatory parameter for the name of the Active Directory OU 
 [parameter(Mandatory=$true)] 
 [string]$AD_OU_DN,
          
 # Mandatory parameter with the active RemoteApp VMS
 [parameter(Mandatory=$true)] 
 [Array]$VMS
 )
 
Import-Module ActiveDirectory
 
#Load the Local Active Directory Admin Credentials
$Local_Cred = Get-AutomationPSCredential -Name 'LocalADCredentials'
 
$disabled_instances = @()
$deleted_instances  = @()
$active_instances   = @()
 
foreach ($vm in $vms) {
  $active_instances += $vm.VirtualMachineName
}
 
$ARAInstances = Get-ADComputer -Filter * -SearchBase $AD_OU_DN -Credential $Local_cred
 
foreach($instance in $ARAInstances) {
  $Name = $instance.Name
  $check = $active_instances -contains $instance.Name 
    
  if( $check -eq $False) {
     if( $instance.Enabled -eq $true) {         
        Set-ADComputer $instance -Enabled $False -Credential $Local_cred
        Write-Output "Disabled : $name"
     } else {
        $instance | Remove-ADObject -Recursive -Confirm:$False -Credential $Local_cred
        Write-Output "Deleted : $name"
     }
   } 
 }
