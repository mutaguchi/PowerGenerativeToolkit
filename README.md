# PowerGenerativeToolkit

PowerGenerativeToolkit is a comprehensive PowerShell module that leverages LLM to generate, transform, and complete all kinds of text, including PowerShell functions. This module makes it easy to create new functions or enhance existing ones by automating the generation process and providing powerful text manipulation capabilities.

日本語版ドキュメントはこの下に用意しています。(A Japanese version of the documentation is available below.)

## Features

- Utilizes OpenAI's API to access gpt-3.5-turbo (default) and gpt-4 language models
- Generates, transforms, and completes various types of text, including PowerShell functions
- Optimized for use in English or Japanese environments, but can also work with other language settings

## System Requirements
- PowerShell 7.0 or later

## Installation

1. Download the .zip file and extract its contents
2. Place the extracted folder in your PowerShell module directory, or use `Import-Module` with the specified PowerGenerativeToolkit.psd1 path to import the module directly

## Configuration

To use PowerGenerativeToolkit, you'll need to set the `OPENAI_API_KEY` environment variable with your OpenAI API key.

## Usage

Currently, only the `Convert-PGTString` command has been implemented. Here's an example of how to use the command:

```powershell
PS> Import-Module PowerGenerativeToolkit
PS> "Toshio Yamada", "Saito Hanako" | Convert-PGTString -Example "Daisuke Mutaguchi=D. Mutaguchi"
T. Yamada
S. Hanako

"frog", "cat", "dog" | Convert-PGTString -Rule "transform into a stronger name" -IncludeInput

Input    Output
-----    ------
frog     Temporalis Amphibia
cat      Felis Magnificus
dog      Canis Canis Regalis

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

## Disclaimer

Please be aware that this module uses OpenAI's API, which may have associated usage fees. Use the module at your own risk, and always be mindful of potential costs.


# PowerGenerativeToolkit

PowerGenerativeToolkitは、LLMを利用してPowerShell関数を含むあらゆる種類のテキストを生成・変換・補完するための包括的なPowerShellモジュールです。

## 機能

- OpenAIのAPIを利用して、gpt-3.5-turbo（デフォルト）およびgpt-4を使用可能
- PowerShell関数を含むさまざまなタイプのテキストを生成、変換、補完（現在は変換のみサポート）
- 日本語も問題なく利用できます

## 動作環境
- PowerShell 7.0以降

## インストール

1. .zipファイルをダウンロードし、内容を解凍します
2. 解凍したフォルダをPowerShellモジュールディレクトリに配置するか、`Import-Module`を使ってPowerGenerativeToolkit.psd1のパスを指定してモジュールを直接インポートします

## 設定

PowerGenerativeToolkitを使用するには、`OPENAI_API_KEY`環境変数にOpenAI APIキーを設定する必要があります。

## 使用方法

現在、`Convert-PGTString`コマンドのみが実装されています。使用例については英語版ドキュメント参照。
他の例は`Get-Help Convert-PGTString -Detailed`で見ることができます。

GPT-3.5/4には日本語も通りますが、英語でRuleやExampleを与えた方が精度が上がるので、適宜、`-CultureInfo en-US`パラメータを指定すると良いでしょう。

## 免責事項

このモジュールはOpenAIのAPIを使用しており、利用料金が発生します。また、モジュールのご利用は自己責任でお願いします。
