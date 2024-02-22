param(
    [Parameter(Mandatory = $true)]
    [string]$OrganizationUrl,
    [Parameter(Mandatory = $true)]
    [string]$ProjectName,
    [Parameter(Mandatory = $true)]
    [int]$PipelineDefinitionId,
    [Parameter(Mandatory = $true)]
    [string]$BranchName
)

Set-StrictMode -Version 3.0

# Import Module
$modulePath = Join-Path -Path $PSScriptRoot -ChildPath "modules\TriggerAdoBuild\TriggerAdoBuild.psm1"
Import-Module -Name $modulePath

# Start ADO build and get the build ID
$buildId = TriggerAdoPipeline -OrganizationUrl $OrganizationUrl -ProjectName $ProjectName -PipelineDefinitionId $PipelineDefinitionId -BranchName $BranchName

# Poll the build status (will poll until an exit code is received)
do {
    $buildStatus = GetAdoBuildStatus -OrganizationUrl $OrganizationUrl -ProjectName $ProjectName -BuildId $buildId

    if ([string]::IsNullOrWhiteSpace($buildStatus)) {
        Write-Information "ADO build is in progress. Sleeping for 10 seconds." -InformationAction Continue
        Start-Sleep -Seconds 10
    }
    elseif ($buildStatus -eq "succeeded") {
        Write-Information "ADO build has succeeded. Exiting." -InformationAction Continue
        Exit 0
    }
    else {
        Write-Error "ADO build has been deleted, cancelled or has failed. Exiting."
        Exit 1
    }

} while ($true)