#!powershell

#AnsibleRequires -CSharpUtil Ansible.Basic

$spec = @{
  options             = @{
    drive_letter = @{ type = "str"; required = $true }
    state        = @{ type = "str"; choices = @('disabled', 'enabled'); default = 'enabled' }
  }
  supports_check_mode = $true
}

$module = [Ansible.Basic.AnsibleModule]::Create($args, $spec)

$drive_letter = $module.Params.drive_letter
$state = $module.Params.state
$check_mode = $module.CheckMode
$diff_before = @{ }
$diff_after = @{ }

$drive_letter = "$($drive_letter):"
$state = $state -eq "enabled"

$module.Result.changed = $false

Function Get-Volume {
  Param(
    [string]$Drive
    )
  Get-CimInstance -ClassName Win32_Volume -Filter "DriveLetter='$Drive'"
}

function Get-TargetResource {
  Param(
    [string]$Drive
  )

  $volume = Get-Volume -Drive $Drive
  if ($null -eq $volume) {
    $module.FailJson("The volume $drive does not exist.")
  }
  $returnValue = @{
    Drive = $Drive
    State = $volume.IndexingEnabled
  }
  return $returnValue
}

function Test-TargetResource {
  Param(
    [string]$Drive,
    [boolean]$IndexingEnabled
  )
  $result = Get-TargetResource -Drive $Drive
  $iscompliant = ($result.State -eq $IndexingEnabled)
  return $iscompliant
}

function Set-TargetResource {
  Param(
    [string]$Drive,
    [boolean]$IndexingEnabled
  )
  $volume = Get-Volume -Drive $Drive
  $diff_before.state= $volume.IndexingEnabled
  $diff_after.state = $IndexingEnabled

  if (-not $check_mode) {
    try {
      $volume | Set-CimInstance -Property @{ IndexingEnabled = $IndexingEnabled } | Out-Null
    }
    Catch { $module.FailJson("An error occurs when changing the IndexingEnabled property: $($_.Exception.Message)", $_) }
  }
  $module.Result.changed = $true
}

$is_compliant = Test-TargetResource -Drive $drive_letter -IndexingEnabled $state

If (-not $is_compliant) {
  Set-TargetResource -Drive $drive_letter -IndexingEnabled $state
}

# Return result
$module.ExitJson()
