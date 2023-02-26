<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: connectorcmdlets PS-Module delivers 
#>

#region Dependencies

# Check if SimplySql module is installed
if (-not(Get-Module -Name PSSQLite)) {
    # Install SimplySql module with administrator rights
    try {
      Start-Process powershell.exe -Verb runAs -ArgumentList "-Command Install-Module -Name PSSQLite -Force -Scope AllUsers" -Wait
    }
    catch {
      Write-Error "Failed to install the SimplySql module with administrator rights. Please install it manually and run the script again."
      return
    }}

Import-Module PSSQLite

#endregion Dependencies

#region Config

#endregion Config

#region Main 

#endregion Main