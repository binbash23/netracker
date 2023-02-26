<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: the collector script takes responsibility of the executed tracker, 
             it also takes care of the Main Database   
#>

#region Dependencies

Import-Module .\win\collector\source\connectorcmdlets\connectorcmdlets.psm1

# Search PSSQLite Module, if it didn't exist, it will be installed 
Search-PSSQLiteModule 

#endregion Dependencies

#region Config
$CollectorConfig.DATABASE_Path
$UUID = New-GUID
$Check_Sys_config_tbl = "CREATE TABLE IF NOT EXISTS 'sys_config' (     'DB_UUID' TEXT,   'CREATE_DATE' datetime not null default (datetime(CURRENT_TIMESTAMP, 'localtime')),   'PROPERTY' TEXT,   'VALUE' TEXT,   PRIMARY KEY('PROPERTY') );"
$VerbosePreference = "Continue" # "SilentlyContinue"

#endregion Config

#region Main 
Write-Verbose "Running $PSCommandPath"

Write-Verbose "Checking collector database..."
if($(Test-path -Path $CollectorConfig.DATABASE_Path) -ne $true)
{
    try {
        Invoke-SqliteQuery -DataSource $CollectorConfig.DATABASE_Path -Query $Check_Sys_config_tbl
        Write-Verbose "collector database created..."
    }
    catch {
        Write-Verbose "collector database creation failed ..."
    }
}

Write-Verbose "Creating initial db entry"
$Initial_Statement = "INSERT INTO sys_config (DB_UUID, PROPERTY, VALUE) VALUES ('$($UUID)', 'Collector DB Created', '100');"
Invoke-SqliteQuery -DataSource $CollectorConfig.DATABASE_Path -Query $Initial_Statement




#endregion Main