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

