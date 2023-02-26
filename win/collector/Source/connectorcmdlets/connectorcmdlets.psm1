<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: connectorcmdlets PS-Module delivers 
#>

#region Dependencies


#endregion Dependencies

#region Config

$CollectorConfig = [ordered]@{
  DATABASE_FILENAME   = "collector.db"
  DATABASE_Path       = $PSScriptRoot + "\collector.db"
  AuthToken           = $null
  StartTime           = $null
  RefreshTime         = $null
}
New-Variable -Name DynDnsSession  -Value $CollectorConfig -Scope Script -Force


#endregion Config

#region cmdlets 

<#
.Synopsis
Checks if the PSSQLite module is installed and installs it with administrator privileges if it is not present.
.DESCRIPTION
The PowerShell function "Search-PSSQLiteModule" begins by checking if the "PSSQLite" module is installed. If it is not installed, the function installs it with administrator privileges. The module is installed by opening PowerShell.exe as an administrator and executing the command "Install-Module -Name PSSQLite -Force -Scope AllUsers". If the installation of the PSSQLite module fails, the function outputs an error message and prompts the user to install the module manually and run the script again. After successful installation of the module, it is imported into the current PowerShell session using the "Import-Module PSSQLite" command.

.EXAMPLE
PS C:\> Search-PSSQLiteModule
This command checks if the PSSQLite module is installed and installs it with administrator privileges if it is not present. If the installation fails, the function outputs an error message and prompts the user to install the module manually and run the script again. After successful installation of the module, it is imported into the current PowerShell session.
#>
function Search-PSSQLiteModule 
{
  
  # Check if PSSQLite module is installed
if (-not(Get-Module -Name PSSQLite)) {
  # Install PSSQLite module with administrator rights
  try {
    Start-Process powershell.exe -Verb runAs -ArgumentList "-Command Install-Module -Name PSSQLite -Force -Scope AllUsers" -Wait
  }
  catch {
    Write-Error "Failed to install the PSSQLite module with administrator rights. Please install it manually and run the script again."
    return
  }}

Import-Module PSSQLite

}

function Get-TimeStamp 
{
  return $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

function New-log2sqlite
{
    try {
      Invoke-SqliteQuery -DataSource $CollectorConfig.DATABASE_Path 
    }
    catch {
      <#Do this if a terminating exception happens#>
    }
}


#endregion cmdlets