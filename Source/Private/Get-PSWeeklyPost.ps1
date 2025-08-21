<#
.SYNOPSIS
Retrieves posts from the PSWeekly API.

.DESCRIPTION
This function interacts with the PSWeekly API to retrieve posts.

.PARAMETER PostId
The ID of the post to retrieve.

.PARAMETER Search
The search term to filter posts.

.PARAMETER Last
The number of posts to retrieve.

.EXAMPLE
Get-PSWeeklyPost -PostId 123

.NOTES
General notes
#>
function Get-PSWeeklyPost {
    [CmdletBinding(DefaultParameterSetName = 'Search')]
    param (
        [Parameter(Mandatory = $false, ParameterSetName = 'PostId')]
        [string]$PostId = $null,
        [Parameter(Mandatory = $false, ParameterSetName = 'Search')]
        [string]$Search = $null,
        [Parameter(Mandatory = $false, ParameterSetName = 'Search')]
        [int]$Last = 1
    )
    if ($PSCmdlet.ParameterSetName -eq 'PostId') {
        $posts = Invoke-PSWeeklyAPI -Path "posts/$PostId"
    }
    elseif (-not [string]::IsNullOrEmpty($Search)) {
        $feed = Invoke-PSWeeklyAPI -Path "posts?search=$Search&orderby=date&order=desc" -MaxResults ($Last * 2) # multiple by 2 to ensure we have enough posts to filter down the mobiles to the last N
        $posts = $feed | Where-Object { $_.slug -notmatch 'mobile' } | Select-Object -First $Last
    }
    else {
        $feed = Invoke-PSWeeklyAPI -Path "posts?orderby=date&order=desc" -MaxResults ($Last * 2) # multiple by 2 to ensure we have enough posts to filter down the mobiles to the last N
        $posts = $feed | Where-Object { $_.slug -notmatch 'mobile' } | Select-Object -First $Last
    }
    
    $posts | Select-Object -Property id, date, @{l = 'title'; e = { $_.title.rendered } }, @{l = 'linktag'; e = { [Regex]::Match($_.content_raw, '(?<=taglistoverride\=\")(.*?)(?=\")').Value } }
}