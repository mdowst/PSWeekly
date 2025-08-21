<#
.SYNOPSIS
Returns the latest PSWeekly post and its associated links.

.DESCRIPTION
This function retrieves the latest PSWeekly post and its associated links.

.PARAMETER OpenBrowser
If specified, opens the post in a web browser.

.EXAMPLE
Get-PSWeekly -OpenBrowser

.NOTES
General notes
#>
function Get-PSWeekly {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [switch]$OpenBrowser = $false
    )
    
    $post = Get-PSWeeklyPost -Last 1
    
    if ($OpenBrowser) {
        Start-Process "https://psweekly.dowst.dev/?p=$($post.id)"
    }
    else {
        Get-PSWeeklyLinks -Tags $post.linktag -MaxResults 0
    }
}