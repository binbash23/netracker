<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: takes care of the Main Database   
#>

#region Dependencies

# The connectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array
Import-Module .\collector\win\connectorcmdlets\connectorcmdlets.psm1

# Search PSSQLite Module, if it didn't exist, it will be installed 
Search-PSSQLiteModule 

#endregion Dependencies

#region Config
$UUID = New-GUID
$CollectorConfig = Get-CollectorConfig
$DB_Path = $PSScriptRoot + '\' + $CollectorConfig.DATABASE_FILENAME
$Create_collector_db = $(get-content  .\collector\create_collector_database.sql -raw)
$VerbosePreference = "Continue" # "SilentlyContinue"
#endregion Config

#region Main 
Write-Verbose "Running $PSCommandPath"
Write-Verbose "Checking collector database... $DB_Path "
if($(Test-path -Path $DB_Path ) -ne $true)
{
    try {
            Invoke-SqliteQuery -DataSource $DB_Path -Query $Create_collector_db
            Write-Verbose "collector database created..."
        }
    catch {
            Write-Verbose "collector database creation failed ..."
          }
}
<#
Write-Verbose "Creating initial db entry"
$Initial_Statement = "INSERT INTO sys_config (DB_UUID, PROPERTY, VALUE) VALUES ('$($UUID)', 'Collector DB Created', '100');"
Invoke-SqliteQuery -DataSource $DB_Path -Query $Initial_Statement
#>



#endregion Main