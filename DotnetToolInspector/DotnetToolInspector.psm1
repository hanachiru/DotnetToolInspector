function Get-DotnetToolRuntimeConfig {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$packageID = "",

        [Parameter(Mandatory = $true)]
        [string]$commandName = "",
        
        [string]$toolPath = "",
        [switch]$global = $false,
        [switch]$local = $false
    )

    # Validate parameters
    if (-not $packageID) {
        throw "Package ID is required."
    }
    if (-not $commandName) {
        throw "Command name is required."
    }
    if (-not $toolPath -and -not $global) {
        $local = $true
    }
    if ($toolPath -and $global) {
        throw "Invalid parameters. Please specify either -toolPath or -global, not both."
    }
    if ($toolPath -and $local) {
        throw "Invalid parameters. Please specify either -toolPath or -global, not both."
    }
    if ($global -and $local) {
        throw "Invalid parameters. Please specify either -toolPath or -global, not both."
    }
    
    if (-not $local) {
        $dotnetToolHome = Get-DotnetToolHome -toolPath $toolPath -global $global

        # NOTE: Global tools can only be installed with one version, so do not specify the version.
        $dotnetToolFolderPath = Join-Path -Path $dotnetToolHome -ChildPath ".store/$packageID"
        if (-not (Test-Path -Path $dotnetToolFolderPath)) {
            throw "Package ID not found: $packageID"
        }
        
        $runtimeConfigContent = Get-RuntimeConfigJsonContent -dotnetToolFolderPath $dotnetToolFolderPath -commandName $commandName
        return $runtimeConfigContent
    }
    elseif ($local) {
        $nugetCachePath = Get-NugetCachePath

        $dotnetToolsJsonPath = Resolve-Path ".config/dotnet-tools.json"
        if (-not (Test-Path -Path $dotnetToolsJsonPath)) {
            throw "File not found: $dotnetToolsJsonPath"
        }
    
        $dotnetToolsJson = Get-Content -Path $dotnetToolsJsonPath | ConvertFrom-Json
        $dotnetToolVersion = $dotnetToolsJson.tools.$packageID.version
        if (-not $dotnetToolVersion) {
            throw "Version not found for package ID: $packageID"
        }
    
        $dotnetToolFolderPath = Join-Path -Path $nugetCachePath -ChildPath "$packageID/$dotnetToolVersion"
        if (-not (Test-Path -Path $dotnetToolFolderPath)) {
            throw "Package ID not found: $packageID"
        }
        $runtimeConfigContent = Get-RuntimeConfigJsonContent -dotnetToolFolderPath $dotnetToolFolderPath -commandName $commandName
        return $runtimeConfigContent
    }
}

function Get-RuntimeConfigJsonContent {
    param (
        [string]$dotnetToolFolderPath,
        [string]$commandName
    )
    $dotnetToolSettingsPath = Get-ChildItem -Path $dotnetToolFolderPath -Recurse -Filter "DotnetToolSettings.xml" | Select-Object -First 1
    if (-not $dotnetToolSettingsPath) {
        throw "File not found: $dotnetToolSettingsPath"
    }
    $dotnetToolContentFolderPath = $dotnetToolSettingsPath.DirectoryName

    [xml]$xmlContent = Get-Content -Path $dotnetToolSettingsPath.FullName
    $commands = $xmlContent.DotNetCliTool.Commands
    $command = $commands.Command | Where-Object { $_.Name -eq $commandName }
    if (-not $command) {
        throw "Command not found: $commandName"
    }

    $runtimeConfigJsonPath = Join-Path -Path $dotnetToolContentFolderPath -ChildPath ($command.EntryPoint -replace ".dll", ".runtimeconfig.json")
    if (-not (Test-Path -Path $runtimeConfigJsonPath)) {
        throw "File not found: $runtimeConfigJsonPath"
    }
    return Get-Content -Path $runtimeConfigJsonPath
}

function Get-DotnetToolHome {
    param (
        [string]$toolPath,
        [switch]$global
    )
    if ($toolPath) {
        return $toolPath
    }
    elseif ($global) {
        if ($IsWindows) {
            if (-not $env:DOTNET_CLI_HOME) {
                return Join-Path -Path $env:USERPROFILE -ChildPath ".dotnet\tools"
            }
            else {
                return Join-Path -Path $env:DOTNET_CLI_HOME -ChildPath ".dotnet\tools"
            }
        }
        else {
            if (-not $env:DOTNET_CLI_HOME) {
                return Join-Path -Path $env:HOME -ChildPath ".dotnet/tools"
            }
            else {
                return Join-Path -Path $env:DOTNET_CLI_HOME -ChildPath ".dotnet/tools"
            }
        }
    }
    throw "Invalid parameters. Unable to determine dotnet tool home."
}

function Get-NugetCachePath {
    if ($IsWindows) {
        if (-not $env:NUGET_PACKAGES) {
            return Join-Path -Path $env:USERPROFILE -ChildPath ".nuget\packages"
        }
        else {
            return $env:NUGET_PACKAGES
        }
    }
    else {
        if (-not $env:NUGET_PACKAGES) {
            return Join-Path -Path $env:HOME -ChildPath ".nuget/packages"
        }
        else {
            return $env:NUGET_PACKAGES
        }
    }
}