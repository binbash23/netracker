<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: takes care of the Main Database   
#>

#region Dependencies
$VerbosePreference = "Continue" # "SilentlyContinue"
# The collectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array

$ModulPath = $PSScriptRoot + '\collectorcmdlets\collectorcmdlets.psm1'
Write-Verbose "path  ... $ModulPath"
Import-Module $ModulPath

#endregion Dependencies

#region Config
$CollectorConfig = Get-CollectorConfig
$DB_Path = $PSScriptRoot + '\' + $CollectorConfig.DATABASE_FILENAME
#endregion Config

#region Main 
Write-Verbose "Running $PSCommandPath"
Write-Verbose "Checking collector database... $DB_Path "
if ($(Test-path -Path $DB_Path ) -ne $true) {
    try {
        Invoke-SqliteQuery -DataSource $DB_Path -Query $(get-content  $($PSScriptRoot.Replace("\win", "") + '\' + $($CollectorConfig.DATABASE_TBL_STRUCTURE)) -raw)
        Write-Verbose "collector database created..."
    }
    catch {
        Write-Verbose "collector database creation failed ..."
    }
}

Write-Verbose "Checking sys_config property: OS..."
try {
    $SQLResponse = Invoke-SqliteQuery -DataSource $DB_Path -Query "select * from sys_config where property='OS'"
    if ($SQLResponse) {
        Write-Verbose " OK"
    }
    else {
        Write-Verbose "Creating OS property..."
        Invoke-SqliteQuery -DataSource $DB_Path -Query "insert into sys_config (PROPERTY, VALUE) values ('OS', 'windows')"
    }
}
catch {
    Write-Verbose "OS Check failed, can't select OS Version from database"
}

Write-Verbose "Checking sys_config property: DATABASE_CREATE_DATE..."
try {
    $SQLResponse = Invoke-SqliteQuery -DataSource $DB_Path -Query "select * from sys_config where property='DATABASE_CREATE_DATE'"
    if ($SQLResponse) {
        Write-Verbose " OK"
    }
    else {
        Write-Verbose "DATABASE_CREATE_DATE is missing, inserting new DATABASE_CREATE_DATE..."
        Invoke-SqliteQuery -DataSource $DB_Path -Query "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_CREATE_DATE', datetime(CURRENT_TIMESTAMP, 'localtime'))"
    }
}
catch {
    Write-Verbose "DATABASE_CREATE_DATE Check failed, can't select DATABASE_CREATE_DATE from database"
}

Write-Verbose "Checking sys_config property: DATABASE_UUID..."
try {
    $SQLResponse = Invoke-SqliteQuery -DataSource $DB_Path -Query "select * from sys_config where property='DATABASE_UUID'"
    if ($SQLResponse) {
        Write-Verbose " OK"
    }
    else {
        Write-Verbose "DATABASE_UUID is missing, inserting new DATABASE_UUID..."
        $UUID = New-GUID
        Invoke-SqliteQuery -DataSource $DB_Path -Query "insert into sys_config (PROPERTY, VALUE) values ('DATABASE_UUID', '$UUID')"
    }
}
catch {
    Write-Verbose "DATABASE_CREATE_DATE Check failed, can't select DATABASE_CREATE_DATE from database"
}

#endregion Main