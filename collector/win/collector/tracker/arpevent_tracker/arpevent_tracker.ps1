<#
Author: Jens Heine & Andreas Stöcker
Purpose: Track arp events and write information in sqlite db 
#>

#region Dependencies

# The connectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array
Import-Module .\win\collector\connectorcmdlets\connectorcmdlets.psm1

# Search PSSQLite Module, if it didn't exist, it will be installed 
Search-PSSQLiteModule 

#endregion Dependencies

#region Config

$DB_FILENAME = 'tracker.db'
$DB_PATH = Join-Path -Path $PSScriptRoot -ChildPath $DB_FILENAME

if (-not(Test-Path -Path $DB_PATH)) {
    # Create new sqlite db file
    #New-Item -ItemType File -Path $DB_PATH | Out-Null
    
    # Create arpevent table
    $create_table_sql = @"
    CREATE TABLE IF NOT EXISTS "arpevent" (
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
    );    
"@
    
    Invoke-SqliteQuery -DataSource $DB_PATH -Query $create_table_sql | Out-Null
}

#endregion Config

#region Main 

Get-NetNeighbor | Select-Object -Property * |
ForEach-Object {
    $uuid = New-Guid
    $insert_sql = @"
INSERT INTO arpevent (
    UUID, 
    IP, 
    InterfaceIndex, 
    AddressFamily,
    InterfaceAlias, 
    LinkLayerAddress, 
    State, 
    InvalidationCount, 
    CreationTime, 
    LastReachableTime, 
    LastUnreachableTime, 
    ReachableTime, 
    UnreachableTime
) 
VALUES (
    '$uuid', 
    '$($_.IPAddress)', 
    '$($_.InterfaceIndex)', 
    '$($_.AddressFamily)',
    '$($_.InterfaceAlias)',
    '$($_.LinkLayerAddress)',
    '$($_.State)', 
    '$($_.InvalidationCount)', 
    '$($_.CreationTime)',
    '$($_.LastReachableTime)', 
    '$($_.LastUnreachableTime)', 
    '$($_.ReachableTime)',
    '$($_.UnreachableTime)'
);
"@
    Invoke-SqliteQuery -DataSource $DB_PATH -Query $insert_sql | Out-Null
}

#endregion Main