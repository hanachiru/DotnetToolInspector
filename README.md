# DotnetToolInspector

English | [日本語](README_JP.md)

`DotnetToolInspector` is a PowerShell module that retrieves the contents of the `runtimeconfig.json` for dotnet tools.

```
# Example of retrieving the runtimeconfig.json for the t4 command of dotnet-t4 v3.0.0
$ Get-DotnetToolRuntimeConfig -packageID "dotnet-t4" -commandName "t4"
{
  "runtimeOptions": {
    "tfm": "net6.0",
    "rollForward": "LatestMajor",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "6.0.0"
    },
    "configProperties": {
      "System.Reflection.Metadata.MetadataUpdater.IsSupported": false
    }
  }
}
```

For example, it helps to check the required .NET SDK version to run the installed dotnet tool. This is particularly useful for determining which .NET SDK to install when using dotnet tools in GitHub Actions.

`DotnetToolInspector` has the following features:

- Supports global tools (`--global` and `--tool-path`) and local tools (`--local`)
- Works on Ubuntu, Windows, and macOS
- Provides `action.yml` for CI/CD usage

# Table of Contents

- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
    - [Global Tools](#global-tools)
    - [Local Tools](#local-tools)
  - [CI/CD](#cicd)
  - [Environment Variables](#environment-variables)

# Requirements

- PowerShell 6 or newer

# Installation

Run the following command in PowerShell:

```shell
$ Install-Module -Name DotnetToolInspector
```

**PowerShell Gallery: [DotnetToolInspector](https://www.powershellgallery.com/packages/DotnetToolInspector)**

# Usage

## Basic Usage

Use `Get-DotnetToolRuntimeConfig` to retrieve the RuntimeConfig of a dotnet tool.

```powershell
Get-DotnetToolRuntimeConfig [-packageID] <string> [-commandName] <string> [[-toolPath] <string>] [-global] [-local] [<CommonParameters>]
```

Below is an example with [dotnet-t4](https://www.nuget.org/packages/dotnet-t4#readme-body-tab). Sample code is also available [here](.github/workflows/sample2.yml).

### Global Tools

```powershell
# for 'dotnet tool install dotnet-t4 --global'
$ Get-DotnetToolRuntimeConfig -packageID "dotnet-t4" -commandName "t4" -global
{
  "runtimeOptions": {
    "tfm": "net6.0",
    "rollForward": "LatestMajor",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "6.0.0"
    },
    "configProperties": {
      "System.Reflection.Metadata.MetadataUpdater.IsSupported": false
    }
  }
}

# for 'dotnet tool install dotnet-t4 --tool-path <path-to-your-tool-path>'
$ Get-DotnetToolRuntimeConfig -packageID "dotnet-t4" -commandName "t4" -toolPath "path\to\your\tool-path"
{
  "runtimeOptions": {
    "tfm": "net6.0",
    "rollForward": "LatestMajor",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "6.0.0"
    },
    "configProperties": {
      "System.Reflection.Metadata.MetadataUpdater.IsSupported": false
    }
  }
}
```

### Local Tools

```powershell
# for 'dotnet tool install dotnet-t4 --local'
$ Get-DotnetToolRuntimeConfig -packageID "dotnet-t4" -commandName "t4"
{
  "runtimeOptions": {
    "tfm": "net6.0",
    "rollForward": "LatestMajor",
    "framework": {
      "name": "Microsoft.NETCore.App",
      "version": "6.0.0"
    },
    "configProperties": {
      "System.Reflection.Metadata.MetadataUpdater.IsSupported": false
    }
  }
}
```

## CI/CD

Sample code is available [here](.github/workflows/sample.yml).

```yaml
name: Sample
on: workflow_dispatch

jobs:
  sample:
    name: Sample
    runs-on: ubuntu-latest
    steps:
      # Checkout Sample Data
      - name: check out
        uses: actions/checkout@v4

      # Check .NET SDK Version
      - name: Example -toolPath
        id: toolpath
        uses: hanachiru/DotnetToolInspector@main
        with:
          package-id: dotnet-t4
          command-name: t4
          tool-path: ./Tests/Data/tool-path

      # Setup .NET
      - name: Setup Dotnet
        uses: actions/setup-dotnet@v4
        with:
          dotnet-version: ${{ steps.toolpath.outputs.framework-version-major-minor }}
```

If you want to retrieve information about local tools, make sure to run `dotnet tool restore` beforehand.

```yml
- name: dotnet tool restore
  working-directory: ./Tests/Data/local
  run: |
    dotnet tool restore
- name: Example -local
  uses: hanachiru/DotnetToolInspector@main
  with:
    package-id: dotnet-t4
    command-name: t4
    working-directory: ./Tests/Data/local
```

## Environment Variables

The following environment variables can modify the behavior. For details, refer to the [official documentation](https://learn.microsoft.com/en-us/dotnet/core/tools/dotnet-environment-variables).

| **Environment Variable** | **Description**                                                                                                                                               | **Default Value**           |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- |
| DOTNET_CLI_HOME          | Specifies the location where supporting files for .NET CLI commands should be written.                                                                        | _Default value for each OS_ |
| NUGET_PACKAGES           | Configures a path to the [NuGet `global-packages` folder](https://learn.microsoft.com/nuget/consume-packages/managing-the-global-packages-and-cache-folders). | _Default value for each OS_ |

The default values of the `DOTNET_CLI_HOME` and `NUGET_PACKAGES` environment variables depend on the operating system used on the runner:
| **Operating System** | `DOTNET_CLI_HOME` | `NUGET_PACKAGES` |
| --------------------- | -------------------------- | -------------------------- |
| **Windows** | `%userprofile%\.dotnet\tools` | `%userprofile%\.nuget\packages` |
| **Ubuntu** | `~/.dotnet/tools` | `~/.nuget/packages` |
| **macOS** | `~/.dotnet/tools` | `~/.nuget/packages` |
