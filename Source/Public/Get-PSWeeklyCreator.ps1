Function Get-PSWeeklyCreator {
    [CmdletBinding()]
    [OutputType()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        [Parameter(Mandatory = $true)]
        [string]$ModuleVersion,
        [Parameter(Mandatory = $true)]
        [string]$Author,
        [Parameter(Mandatory = $true)]
        [string]$PSVersion,
        [Parameter(Mandatory = $false)]
        [string[]]$Functions
    )
    
    New-ModuleTemplate -ModuleName $ModuleName -ModuleVersion $ModuleVersion -Author $Author -PSVersion $PSVersion -Functions $Functions
}