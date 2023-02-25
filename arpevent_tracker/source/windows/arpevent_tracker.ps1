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
    #$line_array = $_.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
    
    $uuid = [guid]::NewGuid().ToString()
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