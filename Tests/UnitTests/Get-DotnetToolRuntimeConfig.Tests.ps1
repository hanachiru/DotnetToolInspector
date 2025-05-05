BeforeAll {
    Import-Module "${PSScriptRoot}/../../DotnetToolInspector" -Force
}

Describe 'Get-DotnetToolRuntimeConfig' {
    Context 'Nomal Scenario' {
        It '-global' {
            $packageID = "dotnet-t4"
            $commandName = "t4"
            $expected = Get-Content "${PSScriptRoot}/../Data/home/.dotnet/tools/.store/dotnet-t4/3.0.0/dotnet-t4/3.0.0/tools/net6.0/any/t4.runtimeconfig.json"

            $env:DOTNET_CLI_HOME = "${PSScriptRoot}/../Data/home"
            $actual = Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -global
            Remove-Item Env:DOTNET_CLI_HOME

            $actual | Should -Be $expected
        }

        It '-toolPath' {
            $packageID = "dotnet-t4"
            $commandName = "t4"
            $expected = Get-Content "${PSScriptRoot}/../Data/tool-path/.store/dotnet-t4/3.0.0/dotnet-t4/3.0.0/tools/net6.0/any/t4.runtimeconfig.json"

            $actual = Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -toolPath "${PSScriptRoot}/../Data/tool-path"
            $actual | Should -Be $expected
        }

        It '-local' {
            $packageID = "dotnet-t4"
            $commandName = "t4"
            $expected = Get-Content "${PSScriptRoot}/../Data/tool-path/.store/dotnet-t4/3.0.0/dotnet-t4/3.0.0/tools/net6.0/any/t4.runtimeconfig.json"

            Push-Location "${PSScriptRoot}/../Data/local"
            $env:NUGET_PACKAGES = "${PSScriptRoot}/../Data/nuget-cache"
            $actual = Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -local
            Remove-Item Env:NUGET_PACKAGES
            Pop-Location
            $actual | Should -Be $expected
        }

        It 'Implicit -local' {
            $packageID = "dotnet-t4"
            $commandName = "t4"
            $expected = Get-Content "${PSScriptRoot}/../Data/tool-path/.store/dotnet-t4/3.0.0/dotnet-t4/3.0.0/tools/net6.0/any/t4.runtimeconfig.json"

            Push-Location "${PSScriptRoot}/../Data/local"
            $env:NUGET_PACKAGES = "${PSScriptRoot}/../Data/nuget-cache"
            $actual = Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName
            Remove-Item Env:NUGET_PACKAGES
            Pop-Location
            $actual | Should -Be $expected
        }
    }

    Context 'Error Scenario' {
        It 'Invalid PackageID (-global)' {
            $packageID = "HogeHoge"
            $commandName = "t4"

            { 
                $env:DOTNET_CLI_HOME = "${PSScriptRoot}/../Data/home"
                Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -global
                Remove-Item Env:DOTNET_CLI_HOME
            } | Should -Throw
        }

        It 'Invalid CommandName (-global)' {
            $packageID = "dotnet-t4"
            $commandName = "HogeHoge"

            { 
                $env:DOTNET_CLI_HOME = "${PSScriptRoot}/../Data/home"
                Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -global
                Remove-Item Env:DOTNET_CLI_HOME
            } | Should -Throw
        }

        It 'Invalid Path (-toolPath)' {
            $packageID = "dotnet-t4"
            $commandName = "t4"

            { Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -toolPath "${PSScriptRoot}/../Data/invalid" } | Should -Throw
        }

        It 'Invalid PackageID (-toolPath)' {
            $packageID = "HogeHoge"
            $commandName = "t4"

            { Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -toolPath "${PSScriptRoot}/../Data/tool-path" } | Should -Throw
        }

        It 'Invalid CommandName (-toolPath)' {
            $packageID = "dotnet-t4"
            $commandName = "HogeHoge"

            { Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -toolPath "${PSScriptRoot}/../Data/tool-path" } | Should -Throw
        }

        It 'Invalid -local' {
            $packageID = "dotnet-t4"
            $commandName = "t4"

            { 
                $env:NUGET_PACKAGES = "${PSScriptRoot}/../Data/nuget-cache"
                Get-DotnetToolRuntimeConfig -packageID $packageID -commandName $commandName -local
                Remove-Item Env:NUGET_PACKAGES
            } | Should -Throw
        }
    }
}