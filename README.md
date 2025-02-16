# PowerGenerativeToolkit

PowerGenerativeToolkit is a comprehensive PowerShell module that leverages LLM to generate, transform, and complete all kinds of text, including PowerShell functions. This module makes it easy to create new functions or enhance existing ones by automating the generation process and providing powerful text manipulation capabilities.

日本語版ドキュメントはこの下に用意しています。(A Japanese version of the documentation is available below.)

## Features

- Utilizes OpenAI's API or compatible APIs to access models like gpt-4o-mini (default)
- Generates, transforms, and completes various types of text, including PowerShell functions
- Optimized for use in English or Japanese environments, but can also work with other language settings

## System Requirements
- PowerShell 7.0 or later

## Installation

1. Download the .zip file and extract its contents
2. Place the extracted folder in your PowerShell module directory, or use `Import-Module` with the specified PowerGenerativeToolkit.psd1 path to import the module directly

## Configuration

To use PowerGenerativeToolkit, you'll need to set the `OPENAI_API_KEY` environment variable with your OpenAI API key. If you are using an OpenAI-compatible API, set the `OPENAI_API_URI` environment variable with the URL of the API.

## Usage

Currently, only the `Convert-PGTString` command has been implemented. Here's an example of how to use the command:

```powershell
PS> $env:OPENAI_API_KEY = "your api key"
PS> Import-Module PowerGenerativeToolkit
PS> "Toshio Yamada", "Saito Hanako" | Convert-PGTString -Example "Daisuke Mutaguchi=D. Mutaguchi"
T. Yamada
S. Hanako

"frog", "cat", "dog" | Convert-PGTString -Rule "transform into a stronger name" -IncludeInput

Input    Output
-----    ------
frog     Temporalis Amphibia
cat      Felis Magnificus
dog      Canis Regalis

1, 2, 3 | Convert-PGTString -Example @{before=5; after=10} -IncludeInput

    Rule:  Double the given number

Input Output
----- ------
1     2
2     4
3     6

PS> $function = "Extracts only even numbers from a given numeric array" | Convert-PGTString -Rule "Generate powershell functions"
PS> $function
function Get-EvenNumbers {
    param(
        [Parameter(Mandatory=$true)]
        [int[]]$numbers
    )

    $evenNumbers = @()
    foreach($number in $numbers) {
        if($number % 2 -eq 0) {
            $evenNumbers += $number
        }
    }

    return ,$evenNumbers
}

PS> Invoke-Expression $function
PS> Get-EvenNumbers @(1..7)
2
4
6
```

You can find other examples by running `Get-Help Convert-PGTString -Detailed`.

## Important Note

Functions in the PowerGenerativeToolkit module, such as Convert-PGTString, only invoke the OpenAI API once, even when multiple values are passed as input via a pipeline or parameters. However, if you execute the function within a loop construct like foreach, the API will be called multiple times. It is generally recommended to avoid executing the function within a loop.

## Disclaimer

Please be aware that this module uses the OpenAI API or compatible APIs, which may incur usage fees. Use this module at your own risk.

# PowerGenerativeToolkit

PowerGenerativeToolkitは、LLMを利用してPowerShell関数を含むあらゆる種類のテキストを生成・変換・補完するための包括的なPowerShellモジュールです。

## 機能

- OpenAIのAPIまたは互換APIを利用して、gpt-4o-mini（デフォルト）等のモデルを使用可能
- PowerShell関数を含むさまざまなタイプのテキストを生成、変換、補完（現在は変換のみサポート）
- 日本語も問題なく利用できます

## 動作環境
- PowerShell 7.0以降

## インストール

1. .zipファイルをダウンロードし、内容を解凍します
2. 解凍したフォルダをPowerShellモジュールディレクトリに配置するか、`Import-Module`を使ってPowerGenerativeToolkit.psd1のパスを指定してモジュールを直接インポートします

## 設定

PowerGenerativeToolkitを使用するには、`OPENAI_API_KEY`環境変数にOpenAI APIキーを設定する必要があります。OpenAI互換APIを使用する場合は、`OPENAI_API_URI`環境変数にAPIのベースURLを設定します。

## 使用方法

現在、`Convert-PGTString`コマンドのみが実装されています。使用例については英語版ドキュメント参照。
他の例は`Get-Help Convert-PGTString -Detailed`で見ることができます。

## 注意
PowerGenerativeToolkitモジュールの関数、例えばConvert-PGTStringなどは、パイプラインやパラメータを通じて複数の値が入力された場合でも、OpenAI APIを1回だけ呼び出します。ただし、foreachなどのループ構文内で関数を実行すると、APIが複数回呼び出されてしまいます。通常は、ループ構文内で関数を実行しないよう、注意してください。

## 免責事項

このモジュールはOpenAI APIや互換APIを使用しており、利用料金が発生する場合があります。また、モジュールのご利用は自己責任でお願いします。
