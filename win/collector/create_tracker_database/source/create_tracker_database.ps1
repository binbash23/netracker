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
$Check_arp_event_tbl='CREATE TABLE IF NOT EXISTS "arpevent" (
	"UUID"	TEXT,
	"CREATE_DATE"	datetime not null default (datetime(CURRENT_TIMESTAMP, "localtime")),
	"IP"	TEXT,
	"HW_TYPE"	TEXT,
	"FLAGS"	TEXT,
	"HW_ADDRESS"	TEXT,
	"MASK"	TEXT,
	"DEVICE"	TEXT,
	PRIMARY KEY("UUID")
);'

$Check_Sys_config_tbl = 'CREATE TABLE IF NOT EXISTS "sys_config" (
  "PROPERTY"      TEXT,
  "VALUE" TEXT,
  PRIMARY KEY("PROPERTY")
);'
$VerbosePreference = "Continue" # "SilentlyContinue"
$DB_PATH = Join-Path -Path $PSScriptRoot -ChildPath $DB_FILENAME

#endregion Config

#region Main 

Write-Verbose "Running $PSCommandPath"

Write-Verbose "Checking netracker database..."
if($(Test-path -Path $($PSScriptRoot + '\' + $DB_FILENAME)) -ne $true)
{
    Invoke-SqliteQuery -DataSource $DB_PATH -Query $Check_Sys_config_tbl
    Invoke-SqliteQuery -DataSource $DB_PATH -Query $Check_arp_event_tbl
}

Write-Verbose "Checking tracker database os..."
try {
  Invoke-SqliteQuery -DataSource $DB_PATH -Query "select * from sys_config where property='TRACKER_OS'"
  Write-Verbose "TRACKER_OS exists."
}
catch {
  Write-Verbose "TRACKER_OS is missing, inserting new TRACKER_OS..."
  Invoke-SqliteQuery -DataSource $DB_PATH -Query "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_OS', 'windows')"
}

Write-Verbose "Checking tracker database create_date..."

try {
  Invoke-SqliteQuery -DataSource $DB_PATH -Query "select * from sys_config where property='TRACKER_DATABASE_CREATE_DATE'"
  Write-Verbose "TRACKER_DATABASE_CREATE_DATE exists."
}
catch {
  Write-Verbose "TRACKER_DATABASE_CREATE_DATE is missing, inserting new TRACKER_DATABASE_CREATE_DATE..."
  Invoke-SqliteQuery -DataSource $DB_PATH -Query "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_DATABASE_CREATE_DATE', datetime(CURRENT_TIMESTAMP, 'localtime'))"
}


Write-Verbose "Checking tracker UUID..."
try {
  Invoke-SqliteQuery -DataSource $DB_PATH -Query "select * from sys_config where property='TRACKER_UUID'"`
  Write-Verbose "UUID exists."
}
catch {
  Write-Verbose "UUID is missing, inserting new UUID..."
  $UUID = [guid]::NewGuid().ToString()
  Invoke-SqliteQuery -DataSource $DB_PATH -Query "insert into sys_config (PROPERTY, VALUE) values ('TRACKER_UUID', '$UUID')"
}

Write-Verbose "Done"

#endregion Main

