# Set $ErrorActionPreference to what's set during Ansible execution
$ErrorActionPreference = "Stop"

#Get Current Directory
$Here = Split-Path -Parent $MyInvocation.MyCommand.Path

.$(Join-Path -Path $Here -ChildPath 'test_utils.ps1')

# Update Pester if needed
Update-Pester

#Get Function Name
$moduleName = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -Replace ".Tests.ps1"

#Resolve Path to Module path
$ansibleModulePath = "$Here\..\..\library\$moduleName.ps1"

Invoke-TestSetup

Function Invoke-AnsibleModule {
    [CmdletBinding()]
    Param(
        [hashtable]$params
    )

    begin {
        $global:complex_args = @{
            "_ansible_check_mode" = $false
            "_ansible_diff"       = $true
        }
        if ($params.ContainsKey('check_mode')) {
            $global:complex_args."_ansible_check_mode" = $params.check_mode
            $params.remove('check_mode')
        }
        if ($params.ContainsKey('diff')) {
            $global:complex_args."_ansible_diff" = $params.diff
            $params.remove('diff')
        }

        $global:complex_args = $global:complex_args + $params
    }
    Process {
        . $ansibleModulePath
        return $module.result
    }
}

$testDriveLetter = 'D'
$fakeIndexingEnabled = (New-Object `
        -TypeName CimInstance `
        -ArgumentList 'Win32_Volume' |
    Add-Member -MemberType NoteProperty -Name IndexingEnabled -Value $true -PassThru |
    Add-Member -MemberType NoteProperty -Name DriveLetter -Value $testDriveLetter -PassThru
)

$fakeIndexingDisabled = (New-Object `
        -TypeName CimInstance `
        -ArgumentList 'Win32_Volume' |
    Add-Member -MemberType NoteProperty -Name IndexingEnabled -Value $false -PassThru |
    Add-Member -MemberType NoteProperty -Name DriveLetter -Value $testDriveLetter -PassThru
)

try {

    Describe 'win_indexing_service validation' {

        Context "test options" {

            Mock Get-CimInstance -MockWith { $fakeIndexingEnabled }
            Mock Set-CimInstance -MockWith {}

            It 'Create a TestError Exception' {

                $params = @{}
                $result = Invoke-AnsibleModule -params $params
                $result | Should -Be $null
            }
        }

        Context 'disable indexing (check mode)' {

            It 'Setting should return changed' {

                Mock Get-CimInstance -MockWith { $fakeIndexingEnabled }

                $params = @{
                    drive_letter = $testDriveLetter
                    state        = 'disabled'
                    check_mode   = $true
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -BeTrue
            }
        }

        Context 'disable indexing' {

            It 'Setting should return changed' {

                Mock Get-CimInstance -MockWith { $fakeIndexingEnabled }
                Mock Set-CimInstance -MockWith {}

                $params = @{
                    drive_letter = $testDriveLetter
                    state        = 'disabled'
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -BeTrue
            }

            It 'test indexing disabled idempotence' {

                Mock Get-CimInstance -MockWith { $fakeIndexingDisabled }

                $params = @{
                    drive_letter = $testDriveLetter
                    state        = 'disabled'
                }
                $result = Invoke-AnsibleModule -params $params
                $result.changed | Should -BeFalse
            }
        }
    }
}
finally {
    Invoke-TestCleanup
}