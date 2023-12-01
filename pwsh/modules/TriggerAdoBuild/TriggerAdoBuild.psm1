Set-StrictMode -Version 3.0

function TriggerAdoPipeline {
    param (
      [string]$OrganizationUrl,
      [string]$ProjectName,
      [int]$PipelineDefinitionId,
      [string]$BranchName
    )

    begin {
        [string]$functionName = $MyInvocation.MyCommand
        Write-Debug "${functionName}:begin:start"
        Write-Debug "${functionName}:begin:OrganizationUrl=$OrganizationUrl"
        Write-Debug "${functionName}:begin:ProjectName=$ProjectName"
        Write-Debug "${functionName}:begin:PipelineDefinitionId=$PipelineDefinitionId"
        Write-Debug "${functionName}:begin:BranchName=$BranchName"
        Write-Debug "${functionName}:begin:end"
    }

    process {
      Write-Debug "${functionName}:process:start"

      $buildId = $(az pipelines build queue --organization $OrganizationUrl --project $ProjectName --definition-id $PipelineDefinitionId --branch $BranchName --query id --output tsv)
      $exitCode = $LASTEXITCODE

      if ($exitCode -ne 0) {
        Write-Error "${functionName} exited with code: $exitCode"
        Exit $exitCode
      }

      Write-Information "ADO pipeline build: $OrganizationUrl/$ProjectName/_build/results?buildId=$buildId&view=results" -InformationAction Continue
      Write-Debug "${functionName}:process:end"

      return $buildId
    }

    end {
      Write-Debug "${functionName}:end:start"
      Write-Debug "${functionName}:end:end"
    }
}

function GetAdoBuildStatus {
  param (
      [string]$OrganizationUrl,
      [string]$ProjectName,
      [int]$BuildId
  )

  begin {
    [string]$functionName = $MyInvocation.MyCommand
    Write-Debug "${functionName}:begin:start"
    Write-Debug "${functionName}:begin:OrganizationUrl=$OrganizationUrl"
    Write-Debug "${functionName}:begin:ProjectName=$ProjectName"
    Write-Debug "${functionName}:begin:BuildId=$BuildId"
    Write-Debug "${functionName}:begin:end"
  }

  process {
    Write-Debug "${functionName}:process:start"

    $result = $(az pipelines build show --organization $OrganizationUrl --project $ProjectName --id $BuildId --query result --output tsv)
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
      Write-Error "${functionName} exited with code: $exitCode"
      Exit $exitCode
    }

    Write-Debug "${functionName}:process:end"

    return $result
  }

  end {
    Write-Debug "${functionName}:end:start"
    Write-Debug "${functionName}:end:end"
  }
}