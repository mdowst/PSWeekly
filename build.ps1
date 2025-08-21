param(
    [Parameter(Mandatory = $false)]    
    [string]$Version = 'v0.0.1'
)

$VersionNumber = [version]::parse($Version.Split('/')[-1].TrimStart('v'))
Set-Location $PSScriptRoot

if(Test-Path .\Build){
    Get-ChildItem -Path .\Build | Remove-Item -Recurse -Force
}

# Generate EzOut formaters
. '.\Source\PSWeekly.EzFormat.ps1'

$linter = . '.\Source\Test\ScriptAnalyzer\ScriptAnalyzer.Linter.ps1'
if ($linter) {
    $linter
    throw "Failed linter tests"
}

Build-Module -SourcePath .\Source -OutputDirectory ..\Build -Version $VersionNumber

#$nuspec = Copy-Item -Path .\Source\PSDates.nuspec -Destination $psd1.DirectoryName -PassThru
#.'nuget.exe' pack "$($nuspec.FullName)" -OutputDirectory .\Build -Version "$($VersionNumber)"