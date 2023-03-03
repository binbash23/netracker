[CmdletBinding()]
param (
    [Parameter()]
    [guid]
    $uuid
)
<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: arpevent tracker  
#>

#region Dependencies
$VerbosePreference = "Continue" # "SilentlyContinue"

# The collectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array
$ModulPath = $(Split-Path $(Split-Path $PSScriptRoot -Parent) -Parent) + '\collectorcmdlets\collectorcmdlets.psm1'

Import-Module $ModulPath

#endregion Dependencies

#region Config
$CollectorConfig = Get-CollectorConfig
$DB_PATH = Join-Path -Path $(Split-Path $(Split-Path $PSScriptRoot -Parent) -Parent) -ChildPath $CollectorConfig.DATABASE_FILENAME
$Query = Get-Content $($PSScriptRoot + '\create_table_arpevent.sql') -Raw
$DB_PATH 

#endregion Config

start-sleep -seconds 5
#region Main 

Write-Verbose "Checking collector database... $DB_Path "

if ($(Test-path -Path $DB_Path ) -eq $true) 
{
    try {
        Invoke-SqliteQuery -DataSource $DB_Path -Query $Query
        Write-Verbose "arpevent tracker table created..."
        New-logEntry -SOURCE $0 -Message "arpevent tracker table created..."

    }
    catch {
        Write-Verbose "arpevent tracker table creation failed ..."
        New-logEntry -SOURCE $0 -Message "arpevent tracker table creation failed ..." -LOCAL_LOG_LEVEL 1

    }

#region insert statement

$table = Get-NetNeighbor -AddressFamily IPv4
$output = @()
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
$output += $obj

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
$insert_sql
New-logEntry -SOURCE $0 -Message "Found arp entry IP:$($obj.IPAddress), MAC: $($obj.MACAddress)"

Invoke-SqliteQuery -DataSource $DB_PATH -Query $insert_sql | Out-Null
}

#endregion insert statement
}
New-logEntry -SOURCE $0 -Message "Finished"

#endregion Main