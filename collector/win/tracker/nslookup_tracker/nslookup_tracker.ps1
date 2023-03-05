<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: nslookup tracker   
#>

#region Dependencies
$VerbosePreference = "Continue" # "SilentlyContinue"
# The collectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array
$ModulPath = Split-Path $(Split-Path $PSScriptRoot -Parent) -Parent + '\collectorcmdlets\collectorcmdlets.psm1'
Import-Module $ModulPath

#endregion Dependencies

#region Config
$CollectorConfig = Get-CollectorConfig
$DB_PATH = Join-Path -Path $PSScriptRoot -ChildPath $DB_FILENAME
$Query = Get-Content $($PSScriptRoot + '\create_table_arpevent.sql') -Raw
#endregion Config

#region Main 


Write-Verbose "Checking collector database... $DB_Path "
if ($(Test-path -Path $DB_Path ) -ne $true) {
    try {
        Invoke-SqliteQuery -DataSource $DB_Path -Query $Query
        Write-Verbose "nslookup tracker table created..."
    }
    catch {
        Write-Verbose "nslookup tracker table creation failed ..."
    }
}

















<#
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
#>
#endregion Main