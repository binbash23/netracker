<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: takes care of the Main Database   
#>

#region Dependencies

# The connectorcmdlets Module will be imported by every tracker module, it contains a set of cmdlets and
# a Module Scope Variable $CollectorConfig in which all Standard Configurations are stored in an array
Import-Module .\collector\win\connectorcmdlets\connectorcmdlets.psm1

#endregion Dependencies

#region Config
$DB_Path = $PSScriptRoot + '\' + $CollectorConfig.DATABASE_FILENAME
$VerbosePreference = "Continue" # "SilentlyContinue"
#endregion Config

#region Main 
Write-Verbose "Running $PSCommandPath"
Write-Verbose "Checking collector database... $DB_Path "
if($(Test-path -Path $DB_Path ) -ne $true)
{
    try {
            Invoke-SqliteQuery -DataSource $DB_Path -Query $CollectorConfig.DATABASE_TBL_STRUCTURE
            Write-Verbose "collector database created..."
        }
    catch {
            Write-Verbose "collector database creation failed ..."
          }
}
Start-Sleep -Seconds 60
#endregion Main