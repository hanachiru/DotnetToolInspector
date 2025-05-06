# DotnetToolInspector

[English](README.md) | 日本語

DotnetToolInspector は dotnet tool の runtimeconfig.json の内容を取得することができる PowerShell のモジュールです。例えばインストールした dotnet tool を動作させるために必要な.NET SDK バージョンの確認に役立ちます。特に GitHub Actions で dotnet tool を利用するためにどの.NET SDK をインストールすれば良いのか特定するのに便利です。

DotnetToolInspector には以下の特徴があります。

- グローバルツール(--global と--tool-path の両方)とローカルツール(--local)に対応
- ubuntu・windows・macos で動作可能
- CI/CD で利用するために action.yml を提供

# 目次

- [要件](#要件)
- [インストール](#インストール)
- [使い方](#使い方)
  - [基本的な使い方](#基本的な使い方)
    - [グローバルツール](#グローバルツール)
    - [ローカルツール](#ローカルツール)
  - [CI/CD](#CI/CD)

# 要件

- PowerShell 6 or newer

# インストール

PowerShell で以下のコマンドを実行します。

```shell
$ Install-Module -Name DotnetToolInspector
```

**PowerShell Gallery : [DotnetToolInspector](https://www.powershellgallery.com/packages/DotnetToolInspector)**

# 使い方

## 基本的な使い方

`Get-DotnetToolRuntimeConfig`を利用して dotnet tool の RuntimeConfig を取得します。

```powershell
Get-DotnetToolRuntimeConfig [-packageID] <string> [-commandName] <string> [[-toolPath] <string>] [-global] [-local] [<CommonParameters>]
```

以下は[dotnet-t4](https://www.nuget.org/packages/dotnet-t4#readme-body-tab)での例です。またサンプルコードは[こちら](.github/workflows/sample2.yml)にあります。

### グローバルツール

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

### ローカルツール

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

サンプルコードは[こちら](.github/workflows/sample.yml)にあります。

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
        uses: hanachiru/DotnetToolInspector/Get-DotnetToolRuntimeConfig@main
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

ローカルツールの情報を取得したい場合は、`dotnet tool restore`を先に実行する必要があるので注意してください。

```
- name: dotnet tool restore
  working-directory: ./Tests/Data/local
  run: |
    dotnet tool restore
- name: Example -local
  uses: hanachiru/DotnetToolInspector/Get-DotnetToolRuntimeConfig@main
  with:
    package-id: dotnet-t4
    command-name: t4
    working-directory: ./Tests/Data/local
```
