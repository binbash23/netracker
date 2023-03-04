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
$ModulPath = $PSScriptRoot + '\collectorcmdlets\collectorcmdlets.psm1'
Import-Module $ModulPath

#endregion Dependencies

#region Config
#$UUID = New-GUID
$CollectorConfig = Get-CollectorConfig
$DB_Path = $PSScriptRoot + '\' + $CollectorConfig.DATABASE_FILENAME
$SOURCE = $MyInvocation.MyCommand.Name
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

New-logEntry -SOURCE $SOURCE -Message "Starting"

# CREATING NEW COLLECTION
$current_collection_uuid = New-Guid
New-logEntry -SOURCE $SOURCE -Message "Creating new collection with UUID: $($current_collection_uuid)" -COLLECTION_UUID $current_collection_uuid

# DETECTING AVAILABLE TRACKERS
New-logEntry -SOURCE $SOURCE -Message "Detecting available trackers..." -COLLECTION_UUID $current_collection_uuid
$TrackerPath = $($PSScriptRoot +"\tracker\")
$tracker_array= Get-ChildItem $TrackerPath -Recurse | Where-Object {$_.FullName -like "*_tracker.ps1"}

New-logEntry -SOURCE $SOURCE -Message "Found $($tracker_array.count) trackers..." -COLLECTION_UUID $current_collection_uuid

foreach($tracker in $tracker_array)
{
    if($(Test-Path -Path $($tracker.FullName)) -eq $true)
    {
        New-logEntry -SOURCE $SOURCE -Message "Starting tracker $($tracker.Name)" -COLLECTION_UUID $current_collection_uuid
        Write-Verbose "Starting tracker $($tracker.FullName)"
        # Erstellen Sie einen neuen Hintergrundjob für das Skript mit Parametern
        $job = Start-Job -FilePath $($tracker.FullName) -ArgumentList $current_collection_uuid, $ModulPath, $($tracker.FullName)

        # Warten Sie, bis der Job abgeschlossen ist, und rufen Sie das Ergebnis ab
        Wait-Job $job
        #$jobResult = Receive-Job $job

        # Geben Sie das Ergebnis des Jobs aus
        #Write-Verbose  $jobResult
   
    } 
}
New-logEntry -SOURCE $SOURCE -Message "Collector Finished" -COLLECTION_UUID $current_collection_uuid

#endregion Main