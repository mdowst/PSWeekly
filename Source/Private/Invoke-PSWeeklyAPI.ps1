<#
.SYNOPSIS
Invokes the PSWeekly API.

.DESCRIPTION
This function interacts with the PSWeekly API to retrieve data.

.PARAMETER Path
The API endpoint path to query.

.PARAMETER PerPage
The number of results to return per page.

.PARAMETER MaxResults
The maximum number of results to return.

.EXAMPLE
Invoke-PSWeeklyAPI -Path "posts" -PerPage 10 -MaxResults 100

.NOTES
General notes
#>
function Invoke-PSWeeklyAPI {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [int]$PerPage = 10,  # WP API max per page is usually 100
        
        [int]$MaxResults = 0  # 0 means no limit, return all results
    )

    $results = @()
    $page = 1

    $Uri = "https://psweekly.dowst.dev/wp-json/wp/v2/$($Path.TrimStart('/'))"

    do {
        # Check if the base URI already has query parameters
        Write-Verbose "Build uri from: $Uri"
        if ($Uri -match '\?') {
            $fullUri = "$Uri&per_page=$PerPage&page=$page"
        }
        else {
            $fullUri = "$($Uri)?per_page=$PerPage&page=$page"
        }
        $response = $null
        try {
            Write-Verbose "Fetching data from: $fullUri"
            $response = Invoke-RestMethod -Uri $fullUri -ErrorAction Stop
        }
        catch {
            try {
                $d = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction Stop
            }
            catch {}
            if ($d.Code -ne 'rest_post_invalid_page_number') {
                Write-Error "Failed to fetch data from $fullUri. Error: $($_)"
            }
            $response = $null
        }
        if ($response.Count -gt 0) {
            $results += $response
            $page++
            
            # Check if we've reached the maximum results limit
            if ($MaxResults -gt 0 -and $results.Count -ge $MaxResults) {
                break
            }
        }
    } while ($response.Count -eq $PerPage)

    # If MaxResults is specified, trim the results to the exact limit
    if ($MaxResults -gt 0 -and $results.Count -gt $MaxResults) {
        $results = $results[0..($MaxResults - 1)]
    }

    return $results
}