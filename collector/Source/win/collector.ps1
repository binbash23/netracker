<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: the collector script takes responsibility of the executed tracker, 
             it also takes care of the Main Database   
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
    }
}

Import-Module PSSQLite

#endregion Dependencies

#region Config

$DB_FILENAME = 'collector.db'
$DB_PATH = Join-Path -Path $PSScriptRoot -ChildPath $DB_FILENAME

$Check_Sys_config_tbl = 'CREATE TABLE IF NOT EXISTS "sys_config" (
    "DB_UUID" TEXT,
  "CREATE_DATE"	 datetime not null default (datetime(CURRENT_TIMESTAMP, "localtime")),
  "PROPERTY"      TEXT,
  "VALUE" TEXT,
  PRIMARY KEY("PROPERTY")
);'
$VerbosePreference = "Continue" # "SilentlyContinue"

#endregion Config

#region Main 

Write-Verbose "Running $PSCommandPath"

Write-Verbose "Checking netracker database..."
if($(Test-path -Path $($PSScriptRoot + '\' + $DB_FILENAME)) -ne $true)
{
    try {
        Invoke-SqliteQuery -DataSource $DB_PATH -Query $Check_Sys_config_tbl
        Write-Verbose "netracker database created..."
    }
    catch {
        Write-Verbose "netracker database creation failed ..."
    }
}


#endregion Main