<#
.SYNOPSIS
Retrieves the tags for PSWeekly links.

.DESCRIPTION
This function fetches the tags available for PSWeekly links.

.PARAMETER Search
The search term to filter tags.

.PARAMETER Last
The number of tags to retrieve.

.EXAMPLE
Get-PSWeeklyTag -Search "PowerShell" -Last 5

.NOTES
General notes
#>
function Get-PSWeeklyTag {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Search')]
        [string]$Search = $null,
        [Parameter(Mandatory = $false, ParameterSetName = 'Search')]
        [int]$Last = 1
    )

    $Tags= Invoke-PSWeeklyAPI -Path "link_library_tags?search=$($Search -replace ' ', '%20')"
    $Tags | Sort-Object name | Select-Object id, name, count, link
}