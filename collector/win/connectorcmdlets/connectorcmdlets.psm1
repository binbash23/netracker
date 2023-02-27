<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: connectorcmdlets PS-Module delivers 
#>

#region Dependencies

#endregion Dependencies

#region Config

$CollectorConfig = [ordered]@{
  DATABASE_FILENAME   = "collector.db"
  DATABASE_TBL_STRUCTURE = $(get-content  ..\create_collector_database.sql -raw)
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
#

function log() {
  param(
  [string]$SOURCE,
  [string]$DESCRIPTION,
  [int]$LOCAL_LOG_LEVEL,
  [int]$COLLECTION_UUID
  )
  $SOURCE = if ([string]::IsNullOrEmpty($SOURCE)) {"unknown"} else {$SOURCE}
  $LOCAL_LOG_LEVEL = if ([string]::IsNullOrEmpty($LOCAL_LOG_LEVEL)) {3} else {$LOCAL_LOG_LEVEL}
  $COLLECTION_UUID = if ([string]::IsNullOrEmpty($COLLECTION_UUID)) {-1} else {$COLLECTION_UUID}
  
  if ($LOCAL_LOG_LEVEL -gt $LOG_LEVEL) {
      # loglevel is too low
      return
  }
  
  switch ($LOCAL_LOG_LEVEL) {
      0 { $LOCAL_LOG_LEVEL = "OFF" }
      1 { $LOCAL_LOG_LEVEL = "CRITICAL" }
      2 { $LOCAL_LOG_LEVEL = "WARN" }
      3 { $LOCAL_LOG_LEVEL = "INFO" }
      4 { $LOCAL_LOG_LEVEL = "DEBUG" }
  }
  
  Write-Host $SOURCE
  Write-Host $LOCAL_LOG_LEVEL
  Write-Host $DESCRIPTION
  Write-Host $COLLECTION_UUID
  
  Invoke-SqliteQuery -DataSource $CollectorConfig.DATABASE_FILENAME -Query "insert into log (LOG_LEVEL, DESCRIPTION, SOURCE, COLLECTION_UUID) values ('$LOCAL_LOG_LEVEL', '$DESCRIPTION', '$SOURCE', '$COLLECTION_UUID')"
}  
#endregion cmdlets


# Search PSSQLite Module, if it didn't exist, it will be installed 
Search-PSSQLiteModule 
$CollectorConfig = Get-CollectorConfig