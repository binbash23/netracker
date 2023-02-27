<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: the collector script takes responsibility of the executed tracker, 
             it also takes care of the Main Database   
#>

#region Dependencies

# The connectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array
Import-Module .\collector\win\connectorcmdlets\connectorcmdlets.psm1

# Search PSSQLite Module, if it didn't exist, it will be installed 
#Search-PSSQLiteModule 

#endregion Dependencies

#region Config
$UUID = New-GUID
$CollectorConfig = Get-CollectorConfig
$DB_Path = $PSScriptRoot + '\' + $CollectorConfig.DATABASE_FILENAME

#$Create_collector_db = $(get-content  .\collector\create_collector_database.sql -raw)
$VerbosePreference = "Continue" # "SilentlyContinue"
#endregion Config

#region Main 
if($(Test-Path -Path $DB_Path) -eq $false)
{
    Start-Process powershell.exe -Verb runAs -ArgumentList "-File `"$PSScriptRoot\create_database.ps1`"" -Wait 
}          

#endregion Main