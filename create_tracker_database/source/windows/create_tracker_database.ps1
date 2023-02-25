<#
Author: Jens Heine & Andreas Stöcker
Purpose: Track arp events and write information in sqlite db 
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
$DB_FILENAME='tracker.db'
$DB_CREATE_SCRIPT_FILENAME='CREATE TABLE IF NOT EXISTS "arpevent" (
  "UUID" TEXT PRIMARY KEY,
  "IP" TEXT NOT NULL,
  "InterfaceIndex" INTEGER,
  "AddressFamily" INTEGER,
  "InterfaceAlias" TEXT,
  "LinkLayerAddress" TEXT,
  "State" INTEGER,
  "InvalidationCount" INTEGER,
  "CreationTime" INTEGER,
  "LastReachableTime" INTEGER,
  "LastUnreachableTime" INTEGER,
  "ReachableTime" INTEGER,
  "UnreachableTime" INTEGER
  ); '
$DB_CREATE_SYS_CONFIG_SCRIPT_FILENAME='CREATE TABLE IF NOT EXISTS "sys_config" (
  "PROPERTY"      TEXT,
  "VALUE" TEXT,
  PRIMARY KEY("PROPERTY")
);
insert or replace into sys_config (property, value) values (#OS#, #windows#);'

$CH_Sys_config_tbl = "Select * from sys_config"
$VerbosePreference = "Continue" # "SilentlyContinue"
$DB_PATH = Join-Path -Path $PSScriptRoot -ChildPath $DB_FILENAME

#endregion Config

#region Main 

Write-Verbose "Running $PSCommandPath"

Write-Verbose "Checking netracker database..."
if($(Test-path -Path $($PSScriptRoot + '\' + $DB_FILENAME)) -ne $true)
{
    Invoke-SqliteQuery -DataSource $DB_PATH -Query $DB_CREATE_SCRIPT_FILENAME
}

Write-Verbose "Checking sys_config table..."
if(!$CH_Sys_config_tbl)
{
    Invoke-SqliteQuery -DataSource $DB_PATH -Query $DB_CREATE_SYS_CONFIG_SCRIPT_FILENAME.Replace("#","'")
}

clear
Write-Verbose "Checking tracker UUID..."
$UUID = Invoke-SqliteQuery -DataSource $DB_PATH "select * from sys_config where property='TRACKER_UUID'"
if ($UUID) {
Write-Verbose "UUID exists."
} else {
Write-Verbose "UUID is missing, inserting new UUID..."
$UUID = [guid]::NewGuid()
Invoke-SqliteQuery -DataSource $DB_PATH "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_UUID', '$UUID')"
}

Write-Verbose "Done"

#endregion Main

