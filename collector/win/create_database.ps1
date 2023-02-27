<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: takes care of the Main Database   
#>

#region Dependencies
$VerbosePreference = "Continue" # "SilentlyContinue"
# The connectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array

$ModulPath = $PSScriptRoot + '\connectorcmdlets\connectorcmdlets.psm1'
Write-Verbose "path  ... $ModulPath"
Import-Module $ModulPath

#endregion Dependencies

#region Config
$CollectorConfig = Get-CollectorConfig
$DB_Path = $PSScriptRoot + '\' + $CollectorConfig.DATABASE_FILENAME

$Query = $(get-content  $($PSScriptRoot.Replace("\win","") + '\' + $($CollectorConfig.DATABASE_TBL_STRUCTURE)) -raw)

#endregion Config

#region Main 
Write-Verbose "Running $PSCommandPath"
Write-Verbose "Checking collector database... $DB_Path "
if($(Test-path -Path $DB_Path ) -ne $true)
{
    try {
            Invoke-SqliteQuery -DataSource $DB_Path -Query $Query
            Write-Verbose "collector database created..."
        }
    catch {
            Write-Verbose "collector database creation failed ..."
          }
}
Start-Sleep -Seconds 60
#endregion Main