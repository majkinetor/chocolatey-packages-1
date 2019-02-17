. "$PSScriptRoot\..\..\scripts\Run-PesterTests.ps1"

$packageName = Split-Path -Leaf $PSScriptRoot

Run-PesterTests `
  -packageName "$packageName" `
  -packagePath "$PSScriptRoot" `
  -licenseShouldMatch "GNU GENERAL PUBLIC LICENSE" `
  -expectedEmbeddedMatch "^Nagstamon-[\d\.]+-win(32|64)_setup.exe$" `
  -expectedDefaultDirectory "${env:ProgramFiles}\Nagstamon*" `
  -customDirectoryArgument "/DIR=" `
  -test32bit

Describe "$packageName configuration verification" {
  Context "Parameters" {
    It "Should create configuration file when 'UseInf' is specified" {
      # Remove the configuration file if it exists
      $confFile = "${env:SystemDrive}\nagstamon.inf"
      if (Test-Path "$confFile") { rm "${confFile}" }
      Install-Package `
        -packageName $packageName `
        -packagePath $PSScriptRoot `
        -additionalArguments "--package-parameters='`"/UseInf:${confFile}`"'" | Should -Be 0

      ${confFile} | Should -Exist

      if (Test-Path "$confFile") { rm "${confFile}" }
    }

    It "Should uninstall package after creating configuration file" {
      Uninstall-Package `
        -packageName $packageName | Should -Be 0
    }

    It "Should use existing configuration file when 'UseInf' is specified" {
      Install-Package `
        -packageName $packageName `
        -packagePath $PSScriptRoot `
        -additionalArguments "--package-parameters='`"/UseInf:${PSScriptRoot}\test.inf`"'" | Should -Be 0
    }

    It "Should have created installation directory" {
      "C:\Testing\Nagstamon" | Should -Exist
    }

    It "Should have created custom start menu directory during install" {
      $programs = [System.Environment]::GetFolderPath('CommonPrograms')
      "$Programs\Nagstamon Custom" | Should -Exist
    }

    It "Should uninstall package after creating configuration file" {
      Uninstall-Package `
        -packageName $packageName
    }

    It "Should have removed directory used in configuration file" {
      "C:\Testing\Nagstamon" | Should -Not -Exist
    }

    It "Should have removed custom start menu directory after uninstall" {
      $programs = [System.Environment]::GetFolderPath('CommonPrograms')
      "$Programs\Nagstamon Custom" | Should -Not -Exist
    }
  }
}
