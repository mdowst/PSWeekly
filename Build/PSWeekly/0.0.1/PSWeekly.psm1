#Region '.\Classes\link_library_links.ps1' -1

Add-Type -AssemblyName System.Web
enum WeeklyCategory {
    Announcements = 58
    BlogsArticlesAndPosts = 12
    BooksMediaAndLearningResources = 4
    Community = 1143
    Fun = 7
    ProjectsScriptsAndModules = 9
    UpcomingEvents = 17
}

class WeeklyCategoryHelper {
    static [hashtable] $DisplayNames = @{
        [WeeklyCategory]::Announcements = "Announcements!"
        [WeeklyCategory]::BlogsArticlesAndPosts = "Blogs, Articles, and Posts"
        [WeeklyCategory]::BooksMediaAndLearningResources = "Books, Media, and Learning Resources"
        [WeeklyCategory]::Community = "Community"
        [WeeklyCategory]::Fun = "Fun"
        [WeeklyCategory]::ProjectsScriptsAndModules = "Projects, Scripts, and Modules"
        [WeeklyCategory]::UpcomingEvents = "Upcoming Events"
    }

    static [hashtable] $DisplayOrder = @{
        [WeeklyCategory]::Announcements = 0
        [WeeklyCategory]::BlogsArticlesAndPosts = 1
        [WeeklyCategory]::BooksMediaAndLearningResources = 2
        [WeeklyCategory]::Community = 3
        [WeeklyCategory]::Fun = 4
        [WeeklyCategory]::ProjectsScriptsAndModules = 5
        [WeeklyCategory]::UpcomingEvents = 6
    }
    
    static [string] GetDisplayName([WeeklyCategory]$category) {
        return [WeeklyCategoryHelper]::DisplayNames[$category]
    }

    static [int] GetDisplayOrder([WeeklyCategory]$category) {
        return [WeeklyCategoryHelper]::DisplayOrder[$category]
    }
}

class link_library_links {
    [String]$Title
    [String]$Link
    [DateTime]$Date
    [String]$Author
    [String]$Description
    [WeeklyCategory]$WeeklyCategory
    [Object[]]$Category
    [Object[]]$Tags
    
    # Property to get the display name of the WeeklyCategory
    [string] GetWeeklyCategoryDisplayName() {
        return [WeeklyCategoryHelper]::GetDisplayName($this.WeeklyCategory)
    }

    link_library_links([object]$InputObject) {
        $this.Title = [System.Web.HttpUtility]::HtmlDecode($InputObject.title.rendered)
        $this.Link = $InputObject.link
        $this.Date = $InputObject.date
        $this.Author = $InputObject.meta.link_submitter_name
        
        $this.Category = $InputObject.link_library_category
        $this.Tags = $InputObject.link_library_tags

        if(-not [string]::IsNullOrEmpty($InputObject.meta.link_description)) {
            $DescriptionStr = $InputObject.meta.link_description.Replace('[expand title=(+) trigclass=my_button trigpos=below swaptitle=(-) targpos=inline] ','').Replace(' [/expand]','')
            $this.Description = [System.Web.HttpUtility]::HtmlDecode($DescriptionStr)
        }
        
        # Find the category ID that matches a WeeklyCategory enum value
        $enumValues = [WeeklyCategory].GetEnumValues()
        $matchingCategoryId = $InputObject.link_library_category | Where-Object { $_ -in $enumValues }
        
        if ($matchingCategoryId) {
            $this.WeeklyCategory = [WeeklyCategory]$matchingCategoryId
        } else {
            $this.WeeklyCategory = [WeeklyCategory]::BlogsArticlesAndPosts # Default fallback
        }
    }
    
}
#EndRegion '.\Classes\link_library_links.ps1' 83
#Region '.\Private\Get-PSWeeklyLinks.ps1' -1

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
#EndRegion '.\Private\Get-PSWeeklyLinks.ps1' 64
#Region '.\Private\Get-PSWeeklyPost.ps1' -1

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
#EndRegion '.\Private\Get-PSWeeklyPost.ps1' 47
#Region '.\Private\Get-PSWeeklyTag.ps1' -1

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
#EndRegion '.\Private\Get-PSWeeklyTag.ps1' 32
#Region '.\Private\Get-WeeklyCategory.ps1' -1

<#
.SYNOPSIS
Retrieves the categories for PSWeekly links.

.DESCRIPTION
This function fetches the categories available for PSWeekly links.

.EXAMPLE
Get-PSWeeklyCategory

.NOTES
General notes
#>
function Get-PSWeeklyCategory {
    [CmdletBinding()]
    param ()

    $Categories= Invoke-PSWeeklyAPI -Path 'link_library_category?parent=0'
    $Categories | Where-Object{ $_.name -ne '_PSWeekly' } | Sort-Object name | Select-Object id, name
}

#EndRegion '.\Private\Get-WeeklyCategory.ps1' 22
#Region '.\Private\Invoke-PSWeeklyAPI.ps1' -1

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
#EndRegion '.\Private\Invoke-PSWeeklyAPI.ps1' 81
#Region '.\Public\Find-PSWeekly.ps1' -1

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
#EndRegion '.\Public\Find-PSWeekly.ps1' 41
#Region '.\Public\Get-PSWeekly.ps1' -1

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
#EndRegion '.\Public\Get-PSWeekly.ps1' 33
#Region '.\Public\Search-PSWeeklyLink.ps1' -1

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
#EndRegion '.\Public\Search-PSWeeklyLink.ps1' 31
