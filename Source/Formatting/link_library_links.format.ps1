$VirtualProperties = [ordered]@{ 
    "Title"      = { "{0}{1}{2}" -f ($PSStyle.Italic+$PSStyle.Foreground.BrightCyan),$_.Title,$PSStyle.Reset }
    "Author"   = { $_.Author }
    "Link" = { $_.Link }
}
$Property = $VirtualProperties.GetEnumerator() | ForEach-Object { $_.Name }
Write-FormatView -TypeName link_library_links -Property $Property -VirtualProperty $VirtualProperties -GroupByScript { $_.GetWeeklyCategoryDisplayName() } -GroupLabel "Category" -Width 45,25 -Wrap

$VirtualProperties = [ordered]@{ 
    "Title"      = { $_.Title }
    "Author"   = { $_.Author }
    "WeeklyCategory"    = { $_.GetWeeklyCategoryDisplayName() }
    "Description" = { $_.Description }
    "Link" = { $_.Link }
}
$Property = $VirtualProperties.GetEnumerator() | ForEach-Object { $_.Name }
Write-FormatView -TypeName link_library_links -Property $Property -VirtualProperty $VirtualProperties -AsList