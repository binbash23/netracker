[CmdletBinding()]
param (
    [Parameter()]
    [switch]
    $h,
    [Parameter()]
    [switch]
    $D,
    [Parameter()]
    [switch]
    $L
)
<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: the collector script takes responsibility of the executed tracker, 
             it also takes care of the database   
#>

#region Dependencies

# The collectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array
Import-Module .\collector\win\collectorcmdlets\collectorcmdlets.psm1

#endregion Dependencies

#region Config
#$UUID = New-GUID
$CollectorConfig = Get-CollectorConfig
$DB_Path = $PSScriptRoot + '\' + $CollectorConfig.DATABASE_FILENAME

$USAGE_INFO_TEXT="

  collector by Jens Heine <binbash@gmx.net> 2023
           and Andreas Stoecker <a.stoecker@gmx.net>

USAGE

   collector [OPTIONS]

OPTIONS
        -D              : Delete/clear log table in database
        -h              : Show usage information
        -L              : Show latest log information from database

  If you start with no options, the collector will create/check the collector
  database and then run all trackers to collect information into the
  collector database.

EXAMPLES

  Show current log/status information:
  ./collector -L     

  Show help:
  ./collector -h

"

$VerbosePreference = "Continue" # "SilentlyContinue" # 
#endregion Config

#region Main 

if($h.IsPresent)
{
    Write-Host $USAGE_INFO_TEXT
    exit
}

if($D.IsPresent)
{
    remove-Log
    exit
}

if($L.IsPresent)
{
    show-Log
    exit
}


if($(Test-Path -Path $DB_Path) -eq $false)
{
    Start-Process powershell.exe -Verb runAs -ArgumentList "-File `"$PSScriptRoot\create_database.ps1`"" -Wait
}          

New-logEntry -SOURCE $0 -Message "Starting"

# CREATING NEW COLLECTION
$current_collection_uuid = New-Guid
New-logEntry -SOURCE $0 -Message "Creating new collection with UUID: $($current_collection_uuid)" 

# DETECTING AVAILABLE TRACKERS
New-logEntry -SOURCE $0 -Message "Detecting available trackers..."
$TrackerPath = $($PSScriptRoot +"\tracker\")
$tracker_array= Get-ChildItem $TrackerPath -Recurse | Where-Object {$_.FullName -like "*_tracker.ps1"}

New-logEntry -SOURCE $0 -Message "Found $($tracker_array.count) trackers..."

foreach($tracker in $tracker_array)
{
    New-logEntry -SOURCE $0 -Message "Starting tracker $($tracker.Name)"
    if($(Test-Path -Path $($tracker.FullName)) -eq $true)
    {
        Write-Verbose "Starting tracker $($tracker.FullName)"
        $File = $($($tracker.FullName) + ' -uuid "' + $current_collection_uuid +'"')
        $FIle
        Start-Process powershell.exe -ArgumentList "-Command", "-File $File" #, "-Wait", "-NoNewWindow"
    } 
}
New-logEntry -SOURCE $0 -Message "Finished"

#endregion Main