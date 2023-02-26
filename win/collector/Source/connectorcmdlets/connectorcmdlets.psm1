<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: connectorcmdlets PS-Module delivers 
#>

#region Dependencies


#endregion Dependencies

#region Config

#endregion Config

#region cmdlets 

<#
.Synopsis
Checks if the SimplySql module is installed and installs it with administrator privileges if it is not present.
.DESCRIPTION
The PowerShell function "Search-SimplySqlModule" begins by checking if the "PSSQLite" module is installed. If it is not installed, the function installs it with administrator privileges. The module is installed by opening PowerShell.exe as an administrator and executing the command "Install-Module -Name PSSQLite -Force -Scope AllUsers". If the installation of the SimplySql module fails, the function outputs an error message and prompts the user to install the module manually and run the script again. After successful installation of the module, it is imported into the current PowerShell session using the "Import-Module PSSQLite" command.

.EXAMPLE
PS C:\> Search-SimplySqlModule
This command checks if the SimplySql module is installed and installs it with administrator privileges if it is not present. If the installation fails, the function outputs an error message and prompts the user to install the module manually and run the script again. After successful installation of the module, it is imported into the current PowerShell session.
#>
function Search-SimplySqlModule 
{
  
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


}

function Get-TimeStamp 
{
  return $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

function create-log2sqlite
{

}


#endregion cmdlets