<#
.SYNOPSIS
Searches for PSWeekly links based on specified criteria.

.DESCRIPTION
This function allows users to search for PSWeekly links using various parameters.

.PARAMETER Search
The search term to filter PSWeekly links.

.PARAMETER MaxResults
The maximum number of results to return. Results are returned in descending order by date. If set to 0, it returns all results.

.EXAMPLE
Search-PSWeeklyLink -Search "VSCode" -MaxResults 5

.NOTES
General notes
#>
function Search-PSWeeklyLink {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'Search')]
        [string]$Search = $null,
        [Parameter(Mandatory = $false, ParameterSetName = 'Search')]
        [int]$MaxResults = 100
    )

    Get-PSWeeklyLinks -Search $Search -MaxResults $MaxResults
}