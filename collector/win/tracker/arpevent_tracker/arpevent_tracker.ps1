param(
   $uuid,
   $ModulePath,
   $ScriptRoot
)
<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: arpevent tracker  
#>

#region Dependencies & config
Import-Module $ModulePath

$VerbosePreference = "Continue" # "SilentlyContinue"
$Path = $(Split-path -path $ScriptRoot -Parent)
$SOURCE = $(Split-path -path $ScriptRoot -Leaf)
$CollectorConfig = Get-CollectorConfig
$DB_PATH = Join-Path -Path $(Split-Path $(Split-Path $Path -Parent) -Parent) -ChildPath $CollectorConfig.DATABASE_FILENAME
$Query = Get-Content $($Path + '\create_table_arpevent.sql') -Raw

#endregion Dependencies & config

#region Main 

Write-Verbose "Checking collector database... $DB_Path "
New-logEntry -SOURCE $SOURCE -Message "Running" -COLLECTION_UUID $uuid -LOCAL_LOG_LEVEL 3

if ($(Test-path -Path $DB_Path ) -eq $true) 
{
Invoke-SqliteQuery -DataSource $DB_Path -Query $Query

#region insert statement
$table = Get-NetNeighbor -AddressFamily IPv4
#$output = @()
foreach ($row in $table) 
{
$ifIndex = $row.ifIndex
$Objectuuid = New-Guid 
$ifDesc = Get-NetAdapter -InterfaceIndex $ifIndex
$obj = [PSCustomObject]@{
    'Objectuuid' = $Objectuuid
    'IPAddress' = $row.IPAddress
    'MACAddress' = $row.LinkLayerAddress
    'Type' = $ifDesc.InterfaceType
    'Flags' = $ifDesc.InterfaceFlags
    'Mask' = $row.State
    'Device' = $ifDesc.InterfaceAlias
}
#$output += $obj

$insert_sql = @" 
insert into arpevent 
(
    UUID,
    COLLECTION_UUID,
    IP,
    HW_TYPE,
    FLAGS, 
    HW_ADDRESS,
    MASK,
    DEVICE 
) VALUES (
    '$($obj.Objectuuid)', 
    '$($uuid)', 
    '$($obj.IPAddress)', 
    '$($obj.Type)',
    '$($obj.Flags)',
    '$($obj.MACAddress)',
    '$($obj.MASK)', 
    '$($obj.Device)'
);
"@

    New-logEntry -SOURCE $SOURCE -Message "Found arp entry IP:$($obj.IPAddress), MAC: $($obj.MACAddress)" -COLLECTION_UUID $uuid -LOCAL_LOG_LEVEL 4

    Invoke-SqliteQuery -DataSource $DB_PATH -Query $insert_sql
}

#endregion insert statement
}

New-logEntry -SOURCE $SOURCE -Message "Tracker Finished" -COLLECTION_UUID $uuid -LOCAL_LOG_LEVEL 3

#endregion Main