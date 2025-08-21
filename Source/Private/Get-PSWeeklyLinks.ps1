<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER Tags
Comma-separated list of tag IDs to filter the links.

.PARAMETER Category
Comma-separated list of category IDs to filter the links.

.PARAMETER Search
Search term to filter the links.

.PARAMETER MaxResults
Maximum number of results to return. 0 means no limit.

.EXAMPLE
Get-PSWeeklyLinks -Tags 1,2 -Category 3 -Search "Azure" -MaxResults 10

.NOTES
General notes
#>


function Get-PSWeeklyLinks {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [int[]]$Tags = @(),
        [Parameter(Mandatory = $false)]
        [int[]]$Category = @(),
        [Parameter(Mandatory = $false)]
        [string]$Search = $null,
        [Parameter(Mandatory = $false)]
        [int]$MaxResults = 0  # 0 means no limit, return all results
    )
    
    $BaseUri = "link_library_links"
    
    $parameters = @()
    if($Tags.Count -gt 0) {
        $parameters += "link_library_tags=" + ($Tags -join ',')
    }
    if($Category.Count -gt 0) {
        $parameters += "link_library_category=" + ($Category -join ',')
    }
    elseif(-not [string]::IsNullOrEmpty($Search)) {
        $parameters += "search=$Search&orderby=date&order=desc"
    }
    if ($parameters.Count -gt 0) {
        $BaseUri += "?$($parameters -join '&')"
    }
    Write-Verbose "Fetching links from: $BaseUri"
    $allLinks = Invoke-PSWeeklyAPI -Path $BaseUri -PerPage 10 -MaxResults $MaxResults

    $return = $allLinks | ForEach-Object { 
        [link_library_links]::new($_)
    }
    $return | Sort-Object WeeklyCategory
}