param(
   $uuid,
   $ModulePath,
   $ScriptRoot
)
<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: sys_scan_tracker  
#>

#region Dependencies & config
Import-Module $ModulePath

$VerbosePreference = "Continue" # "SilentlyContinue"
$Path = $(Split-path -path $ScriptRoot -Parent)
$SOURCE = $(Split-path -path $ScriptRoot -Leaf)
$CollectorConfig = Get-CollectorConfig
$DB_PATH = Join-Path -Path $(Split-Path $(Split-Path $Path -Parent) -Parent) -ChildPath $CollectorConfig.DATABASE_FILENAME
$Query = Get-Content $($Path + '\create_table.sql') -Raw

#endregion Dependencies & config

#region Main 

Write-Verbose "Checking collector database... $DB_Path "
New-logEntry -SOURCE $SOURCE -Message "Running" -COLLECTION_UUID $uuid -LOCAL_LOG_LEVEL 3

if ($(Test-path -Path $DB_Path ) -eq $true) 
{
    Invoke-SqliteQuery -DataSource $DB_Path -Query $Query
    $SELECT_ENABLED_QUERY = "SELECT CLASS WHERE ENABLED=1 FROM track_wmiObject"
    $ENABLED_CLASSES = Invoke-SqliteQuery -DataSource $DB_Path -Query $SELECT_ENABLED_QUERY

    if($ENABLED_CLASSES)
    {
        foreach($CLASS IN $ENABLED_CLASSES)
        {
            New-logEntry -SOURCE $SOURCE -Message "$CLASS is enabled, start job..." -COLLECTION_UUID $uuid -LOCAL_LOG_LEVEL 3
            Start-Job -FilePath ($Path + "wmi_object_info.ps1") -ArgumentList $uuid, $ModulPath, ($Path + "wmi_object_info.ps1"), $myClass
        }
        
        # Warten auf den Abschluss der Jobs und Ausgabe der Ergebnisse
        $results = foreach ($job in $jobs) {
            Wait-Job $job | Receive-Job
        }

        $results  # Ausgabe der Job-Ergebnisse

    }
    else {
        New-logEntry -SOURCE $SOURCE -Message "No wmi_object Classes in track_wmiObject are set as enabled" -COLLECTION_UUID $uuid -LOCAL_LOG_LEVEL 2

    }

<#    
$DeviceProperties = Get-ComputerInfo | Get-Member -MemberType Property #| Select-Object -First 3
$CreateString  = ''
$InsertString1 = ''
$InsertString2 = ''
foreach($Info in $DeviceProperties)
{
    $CreateString2add = '"' + $($Info.Name) + '" TEXT,'
    $CreateString +=  $CreateString2add 
    
    $InsertString2add1 = $($Info.Name) + ','
    $InsertString1 +=  $InsertString2add1 
    
    $InsertProperty = $(Get-ComputerInfo -Property $($Info.Name)).$($Info.Name) 
    $InsertString2add2 = "'" + $InsertProperty + "',"
    $InsertString2 +=  $InsertString2add2 

}
    
$GenericCreateSQL = 'CREATE TABLE IF NOT EXISTS "t_osenv" (
                                                                "UUID"  TEXT,
                                                                "CREATE_DATE" datetime not null default (datetime(CURRENT_TIMESTAMP, ''localtime'')),
                                                                "COLLECTION_UUID"  TEXT,
                                                                
                                                                ' + $CreateString  + '
    
                                                                PRIMARY KEY("UUID")
                                                            );'
$GenericInsertSQL  = @"
insert into t_osenv (
    UUID,
    COLLECTION_UUID,
    $($InsertString1.Substring(0, $InsertString1.Length - 1))
) VALUES (
    '$(New-GUID)', 
    '$($uuid)', 
    $($InsertString2.Substring(0, $InsertString2.Length - 1))
);
"@

$GenericInsertSQL
    
Invoke-SqliteQuery -DataSource $DB_Path -Query $GenericCreateSQL
Invoke-SqliteQuery -DataSource $DB_Path -Query $GenericInsertSQL
#>


}

New-logEntry -SOURCE $SOURCE -Message "Tracker Finished" -COLLECTION_UUID $uuid -LOCAL_LOG_LEVEL 3

#endregion Main