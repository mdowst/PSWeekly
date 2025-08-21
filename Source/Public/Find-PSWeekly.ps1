<#
.SYNOPSIS
Get a list of PSWeekly posts based on month and year.

.DESCRIPTION
This function retrieves PSWeekly posts filtered by a specific month and year. If the month is not set or set to 13, it retrieves all posts for the specified year.

.PARAMETER Month
Month to filter the results.

.PARAMETER Year
Year to filter the results.

.EXAMPLE
Find-PSWeekly -Month 5 -Year 2024

.NOTES
General notes
#>
function Find-PSWeekly {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 12)]
        [int]$Month = 13,  # 13 means no month filter
        [Parameter(Mandatory = $true)]
        [ValidateRange(2000, 2100)]
        [int]$Year
    )

    if ($Month -ne 13) {
        $monthName = (Get-Culture en-US).DateTimeFormat.GetMonthName($Month)
        $Search = "$monthName $Year"
    } else {
        $Search = "$Year"
    }
    $posts = Get-PSWeeklyPost -Search $Search -Last 52

    $posts
}