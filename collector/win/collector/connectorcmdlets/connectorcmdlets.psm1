<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: connectorcmdlets PS-Module delivers 
#>

#region Dependencies

#endregion Dependencies

#region Config

$CollectorConfig = [ordered]@{
  DATABASE_FILENAME   = "collector.db"
  loglevel            = 4
}
New-Variable -Name CollectorConfig -Value $CollectorConfig -Force

#endregion Config

#region cmdlets 

function Get-CollectorConfig {
  $CollectorConfig | ConvertTo-Json | ConvertFrom-Json
}


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
if (-not(Get-Module -Name PSSQLite)) 
{
  try   {
          Import-Module PSSQLite
        }
  catch {
          Write-Error "Import-Module PSSQLite failed"
        try   {
                # Install PSSQLite module with administrator rights
                Start-Process powershell.exe -Verb runAs -ArgumentList "-Command Install-Module -Name PSSQLite -Force -Scope AllUsers" -Wait -PassThru
              }
        catch {
                Write-Error "Failed to install the PSSQLite module with administrator rights. Please install it manually and run the script again."
                Exit
              }
  }}
}

function Get-TimeStamp 
{
  return $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
}

function New-GUID {
  return [guid]::NewGuid().ToString()  
}

# Loglevel for every process. Possible values are:
# 0=OFF
# 1=CRITICAL
# 2=WARN
# 3=INFO
# 4=DEBUG

function New-log2sqlite
{
  [CmdletBinding()]
  param (
      [Parameter()]
      [string]
      $DESCRIPTION,
      [Parameter()]
      [string]
      $logLevel = ''
  )
    try {
      Invoke-SqliteQuery -DataSource $CollectorConfig.DATABASE_Path 
    }
    catch {
      <#Do this if a terminating exception happens#>
    }
}


#endregion cmdlets