<#
    Author: Jens Heine & Andreas Stöcker
    Purpose: the collector script takes responsibility of the executed tracker, 
             it also takes care of the Main Database   
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

$DB_FILENAME = 'collector.db'
$DB_PATH = Join-Path -Path $PSScriptRoot -ChildPath $DB_FILENAME

#endregion Config

#region Main 

#endregion Main