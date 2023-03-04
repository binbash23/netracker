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

function check-tracker {
    param (
    [string]$tracker_name
    )
    if ([string]::IsNullOrWhiteSpace($tracker_name)) {
        Write-Verbose "Error: Tracker name is empty."
        exit 1
    }
    Write-Verbose "tracker_name: $tracker_name"
    $entry_exists = Invoke-SqliteQuery -DataSource $DB_Path -Query "select count(*) as Value from tracker_config where name ='$tracker_name'"
    Write-Verbose "entry_exists: $($entry_exists.VALUE)"

    if ($($entry_exists.VALUE) -eq 0) {
        New-logEntry -SOURCE $SOURCE -Message "Register new tracker in tracker_config: $tracker_name default enabled=1" -COLLECTION_UUID $current_collection_uuid
        Invoke-SqliteQuery -DataSource $DB_Path -Query "insert into tracker_config (NAME, ENABLED) values ('$tracker_name', 1)"
        Write-Verbose 1
        return 1
    } else {
        $enabled = Invoke-SqliteQuery -DataSource $DB_Path -Query "select enabled from tracker_config where name='$tracker_name'"
        New-logEntry -SOURCE $SOURCE -Message "Found tracker in config with status=$($enabled.ENABLED)" -COLLECTION_UUID $current_collection_uuid

        if ($($enabled.ENABLED) -eq 1) {
            Write-Verbose 1
            return 1
        } else {
            Write-Verbose 0
            return 0
        }
    }
}    

function get_collector_sleep_interval_from_configuration {
    $sleep_interval= Invoke-SqliteQuery -DataSource $DB_Path "select value from sys_config where property='COLLECTOR_INTERVAL_SEC'"
    if(!$sleep_interval)
    {
        $sleep_interval = 5
    }
    return $sleep_interval;
  }
  


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


while ($true) {
    

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
             
        $is_tracker_enabled = $(check-tracker -tracker_name $($tracker.Name).Replace('_tracker.ps1',''))
        Write-Verbose "tracker enabled?  $is_tracker_enabled"
        if($is_tracker_enabled -eq 0)
        {
            New-logEntry -SOURCE $SOURCE -Message "Tracker $($tracker.Name) is disabled. Skipping start." -COLLECTION_UUID $current_collection_uuid -LOCAL_LOG_LEVEL 3
            Continue
        }
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
Write-Verbose "Sleeping for $($(get_collector_sleep_interval_from_configuration).Value)"
Start-Sleep -Seconds $(get_collector_sleep_interval_from_configuration).Value

}
New-logEntry -SOURCE $SOURCE -Message "Collector Finished" -COLLECTION_UUID $current_collection_uuid

#endregion Main