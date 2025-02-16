#requires -Version 7.0

function Convert-PGTString
{
    <#
.SYNOPSIS
Converts input strings based on the specified rule or examples using the OpenAI or compatible API.

.DESCRIPTION
The Convert-PGTString function uses OpenAI's gpt-4o-mini (default) or other models (when -Model parameter is specified) to transform input strings based on the provided rule or examples. It can handle various transformation scenarios and provides powerful string conversion capabilities. Make sure to set your OpenAI API key in the OPENAI_API_KEY environment variable before using this function. OPENAI_API_URI environment variable can be set to use a custom API endpoint.

.NOTES
The Convert-PGTString function only invokes the OpenAI API once, even when multiple values are passed as input via a pipeline or parameters. However, if you execute the function within a loop construct like foreach, the API will be called multiple times. It is generally recommended to avoid executing the function within a loop.

.PARAMETER InputString
The input strings to be transformed.

.PARAMETER Example
An array of examples provided as strings in the format "Before=After" or as hashtables with keys 'before' and 'after'. These examples are used to guide the transformation process.

.PARAMETER Rule
A string specifying the rule for transformation. Either Rule or Example (or both) must be provided.

.PARAMETER Model
When specified, uses the specified model for the transformation. The default model is gpt-4o-mini.

.PARAMETER IncludeRule
When specified, includes the rule in the output object.

.PARAMETER IncludeInput
When specified, includes the input string in the output object.

.PARAMETER CultureInfo
Allows specifying a custom culture for the output, otherwise it defaults to the current system culture.

.EXAMPLE
PS> "Toshio Yamada", "Saito Hanako" | Convert-PGTString -Example "Daisuke Mutaguchi=D. Mutaguchi"
T. Yamada
S. Hanako

This example demonstrates the use of Convert-PGTString with a single example and multiple input strings. The input strings "Toshio Yamada" and "Saito Hanako" are transformed based on the provided example.

.EXAMPLE
PS> "frog", "cat", "dog" | Convert-PGTString -Rule "transform into a stronger name" -IncludeInput

Input    Output
-----    ------
frog     Temporalis Amphibia
cat      Felis Magnificus
dog      Canis Regalis

This example demonstrates the use of Convert-PGTString with the -Rule parameter and -IncludeInput switch. The input strings "frog", "cat", and "dog" are transformed based on the specified rule "transform into a stronger name". The output objects include both the original input strings and their transformed versions.

.EXAMPLE
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

This example showcases the generation of a PowerShell function that extracts even numbers from a given numeric array. The function is then executed using Invoke-Expression.

.EXAMPLE
PS> 1, 2, 3 | Convert-PGTString -Example @{before=5; after=10} -IncludeInput

    Rule:  Double the given number

Input Output
----- ------
1     2
2     4
3     6

This example demonstrates the use of Convert-PGTString with a single example in the form of a hashtable. The input numbers 1, 2, and 3 are transformed based on the provided example, which indicates that the transformation rule is to double the given number. The output objects include both the original input numbers and their transformed versions.

.EXAMPLE
PS> $array = Convert-PGTString -InputString 7,9,15 -Example "2=Yes","3=Yes","4=No","5=Yes","6=No","11=Yes" -IncludeRule -CultureInfo en-US
PS> $array.Rule
Determine prime number or not (Yes/No)
PS> $array.StringPairs | Where-Object Output -eq Yes

Input Output
----- ------
7     Yes

This example demonstrates the use of Convert-PGTString with multiple examples in the form of a string array. The input numbers 7, 9, and 15 are transformed based on the provided examples, which indicate the transformation rule is to determine whether the given numbers are prime (Yes) or not (No). Specifying the CultureInfo as en-US may result in better accuracy compared to ja-JP in some cases. The output objects, which include the transformation rule and the input-output pairs, can be assigned to variables or passed through the pipeline for further processing.

In this case, the pipeline is used to filter the output objects based on the 'Yes' value, effectively showing only prime numbers in the result.
#>    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline)][string[]]$InputString,
        [PSObject[]]$Example, [string]$Rule, [string]$Model = "gpt-4o-mini", [switch]$IncludeRule, [switch]$IncludeInput, [CultureInfo] $CultureInfo
    )

    begin
    {
        $apiKey = $env:OPENAI_API_KEY
        $grammar = ""
        if (-not $env:OPENAI_API_URI)
        {
            $uri = "https://api.openai.com/v1/chat/completions"
        }
        else
        {
            $uri = $env:OPENAI_API_URI

            # Copied from https://github.com/ggml-org/llama.cpp/blob/master/grammars/json.gbnf
            # Copyright (c) 2023-2024 The ggml authors
            # Licensed under the MIT License
            $grammar = @'
root   ::= object
value  ::= object | array | string | number | ("true" | "false" | "null") ws

object ::=
  "{" ws (
            string ":" ws value
    ("," ws string ":" ws value)*
  )? "}" ws

array  ::=
  "[" ws (
            value
    ("," ws value)*
  )? "]" ws

string ::=
  "\"" (
    [^"\\\x7F\x00-\x1F] |
    "\\" (["\\bfnrt] | "u" [0-9a-fA-F]{4}) # escapes
  )* "\"" ws

number ::= ("-"? ([0-9] | [1-9] [0-9]{0,15})) ("." [0-9]+)? ([eE] [-+]? [0-9] [1-9]{0,15})? ws

# Optional space: by convention, applied in this grammar after literal chars when allowed
ws ::= | " " | "\n" [ \t]{0,20}
'@
        }

        $msgTable = @{Examples = @(
                @{
                    rule     = "Expand abbreviations"
                    examples = @(
                        @{before = "ASAP"; after = "as soon as possible" }
                    )
                    answers  = @(
                        @{before = "TTYL"; after = "talk to you later" },
                        @{before = "FYI"; after = "for your information" },
                        @{before = "BRB"; after = "be right back" }
                    )
                },
                @{
                    rule     = "Make phrases formal"
                    examples = @(
                        @{before = "gonna"; after = "going to" }
                    )
                    answers  = @(
                        @{before = "wanna"; after = "want to" },
                        @{before = "gimme"; after = "give me" },
                        @{before = "kinda"; after = "kind of" }
                    )
                },
                @{
                    rule     = "Provide description"
                    examples = @(
                        @{before = "Mitochondria"; after = "Powerhouse of the cell, responsible for producing energy" },
                        @{before = "Nucleus"; after = "Control center of the cell, contains DNA" }
                    )
                    answers  = @(
                        @{before = "Ribosome"; after = "Site of protein synthesis in the cell" },
                        @{before = "Golgi Apparatus"; after = "Modifies, sorts, and packages proteins and lipids" },
                        @{before = "Lysosome"; after = "Digests and breaks down waste materials in the cell" }
                    )
                },
                @{
                    rule     = "Create PowerShell Function"
                    examples = @(
                        @{before = "Add a date to the file name."; after = 'function Add-DateToFileName {
    param(
        [string]$Path
    )

    if (Test-Path -Path $Path) {
        $directory = Split-Path -Path $Path -Parent
        $fileName = Split-Path -Path $Path -Leaf
        $datePrefix = (Get-Date).ToString("yyyyMMdd")
        $newFileName = $datePrefix + "_" + $fileName
        Rename-Item -Path $Path -NewName $newFileName
    }       
}' 
                        }
                    )
                    answers  = @(
                        @{before = "Calculate the total size of image files in the current folder."; after = 'function Get-PictureFileSize {
Get-ChildItem | Where-Object {{$_.Extension -in ".png",".gif",".jpg"}}|Measure-Object -Property Length -Sum|Select-Object -ExpandProperty "Sum"
}'
                        }
                    )
                }
            )
        }

        [cultureinfo]$culture = if ($null -eq $CultureInfo) { Get-UICulture } else { $CultureInfo }
        Import-LocalizedData -BindingVariable msgTable -UICulture $culture -ErrorAction:SilentlyContinue
        $examples = $msgTable.Examples
        
        $ruleWithExample = -not [string]::IsNullOrEmpty($Rule) -and $null -ne $Example
        $ruleOnly = -not $ruleWithExample -and $null -eq $Example
        $exampleOnly = -not $ruleWithExample -and -not $ruleOnly
        
        $in = @()

        function ConvertTo-JsonStringArray
        {
            param(
                [hashtable]$example,
                [switch]$rulewithExample,
                [switch]$exampleOnly,
                [switch]$ruleOnly
            )

            $inputObj = [ordered]@{
                inputs = @($example.answers | ForEach-Object { $_.before })
            }

            $outputObj = [ordered]@{
                outputs = @($example.answers | ForEach-Object { $_.after })
            }

            if ($rulewithExample)
            {
                $rulewithExampleObj = [ordered]@{
                    rule     = $example.rule;
                    examples = $example.examples;
                } + $inputObj

                $rulewithExampleJson = $rulewithExampleObj | ConvertTo-Json -Compress
                $outputJson = $outputObj | ConvertTo-Json -Compress

                @($rulewithExampleJson, $outputJson)
            }
            elseif ($exampleOnly)
            {
                $exampleOnlyObj = [ordered]@{
                    examples = $example.examples;
                } + $inputObj

                $exampleOnlyJson = $exampleOnlyObj | ConvertTo-Json -Compress
                $outputJson = ([ordered]@{ rule = $example.rule } + $outputObj ) | ConvertTo-Json -Compress

                @($exampleOnlyJson, $outputJson)
            }
            elseif ($ruleOnly)
            {
                $ruleOnlyObj = [ordered]@{
                    rule = $example.rule;
                } + $inputObj

                $ruleOnlyJson = $ruleOnlyObj | ConvertTo-Json -Compress
                $outputJson = $outputObj | ConvertTo-Json -Compress

                @($ruleOnlyJson, $outputJson)
            }
        }
    }
    process
    {
        foreach ($i in $inputString)
        {
            $in += $i
        }
    }
    end
    {
        $convertedExamples = @($Example | ForEach-Object {
                if ($_ -is [string])
                {
                    $split = $_ -split '='
                    [ordered]@{before = $split[0]; after = $split[1] }
                }
                else
                {
                    [ordered]@{before = $_.before; after = $_.after }
                }
            })
        $emptyAnswers = @($in | ForEach-Object {
                [ordered]@{before = $_; after = "" }
            })
        $inputDic = [ordered]@{
            'rule'     = $Rule
            'examples' = $convertedExamples
            'answers'  = $emptyAnswers
        }

        $system = if ($exampleOnly)
        {
            'You are tasked with discovering a rule from the given examples and using that rule to transform input strings into output strings. You will be provided with a single JSON object containing one or more examples and one or more input strings.

For instance, consider the following examples and inputs:
{"examples":[{"before":"Daisuke Mutaguchi","after":"D. Mutaguchi"},{"before":"Taro Tanaka","after":"T. Tanaka"}],"inputs":["Toshio Yamada","Hanako Honda"]}

From the example, you should deduce the rule of converting the full first name to its initial followed by a period, while keeping the last name unchanged. Then, apply this rule to the input strings, and output the results with a single JSON object containing one rule and one or more output strings. In this case, the output should be:
{"rule":"Convert the full first name to its initial followed by a period","outputs":["T. Yamada","H. Honda"]}

Do not include words from the input in the output.

Now, as you''ll be given various strings as input, continue to deduce the rules and apply the transformations accordingly.

Never include non-JSON strings in the output, such as warning text, annotations, etc. Always output JSON.'
        }
        elseif ($ruleWithExample)
        {
            'You are tasked with using the given rule and referring to the examples to transform input strings into output strings. First, you will be provided with a single JSON object containing one rule, one or more examples and one or more input strings.

For instance, consider the following rule, examples and inputs:
{"rule":"Convert the full first name to its initial followed by a period","examples":[{"before":"Daisuke Mutaguchi","after":"D. Mutaguchi"},{"before":"Taro Tanaka","after":"T. Tanaka"}],"inputs":["Toshio Yamada","Hanako Honda"]}

Using the provided rule and referring to the examples, apply the rule to the input strings, and output the results with a single JSON object containing one or more output strings. In this case, the output should be:
{"outputs":["T. Yamada","H. Honda"]}

Do not include words from the input in the output.

Now, as you''ll be given various rules and strings as input, continue to refer to the examples and apply the given rules to perform the transformations accordingly.

Never include non-JSON strings in the output, such as warning text, annotations, etc. Always output JSON.'
        }
        elseif ($ruleOnly)
        {
            'You are tasked with using the given rule to transform input strings into output strings. First, you will be provided with a single JSON object containing one rule and one or more input strings.

For instance, consider the following rule and inputs:
{"rule":"Convert the full first name to its initial followed by a period","inputs":["Toshio Yamada","Hanako Honda"]}

Using the provided rule, apply the rule to the input strings, and output the results with a single JSON object containing one or more output strings. In this case, the output should be:
{"outputs":["T. Yamada","H. Honda"]}

Do not include words from the input in the output.

Now, as you''ll be given various rules and strings as input, continue to apply the given rules to perform the transformations accordingly.

Never include non-JSON strings in the output, such as warning text, annotations, etc. Always output JSON.'
        }

        $system_message = @([ordered]@{
                "role"    = "system"
                "content" = $system
            })

        $example_messages = @(
            foreach ($e in $examples)
            {
                $user, $assistant = ConvertTo-JsonStringArray -example $e `
                    -rulewithExample:$rulewithExample `
                    -exampleOnly:$exampleOnly `
                    -ruleOnly:$ruleOnly
                [ordered]@{
                    "role"    = "user"
                    "content" = $user
                },
                [ordered]@{
                    "role"    = "assistant"
                    "content" = $assistant
                }
            }
        )

        $user_message = @(
            [ordered]@{
                "role"    = "user"
                "content" = ConvertTo-JsonStringArray -example $inputDic `
                    -rulewithExample:$rulewithExample `
                    -exampleOnly:$exampleOnly `
                    -ruleOnly:$ruleOnly | Select-Object -First 1
            }
        )

        $messages = $system_message + $example_messages + $user_message
        
        $body = [ordered]@{
            model      = $model
            messages   = $messages
            max_tokens = [int]([math]::Round((ConvertTo-Json $example_messages).Length / $example_messages.Length) * 2)
        }
        
        if ($grammar -ne "")
        {
            $body.Add("grammar", $grammar)
        }

        $headers = [ordered]@{}

        if (-not [string]::IsNullOrEmpty($apiKey))
        {
            $headers.Add("Authorization", "Bearer $($ApiKey)")
        }
        $headers.Add("Content-Type", "application/json")

        $body = $body | ConvertTo-Json 
        $byte = [System.Text.Encoding]::UTF8.GetBytes($body)
        $response = Invoke-RestMethod -Method 'POST' -Uri $uri -Headers $headers -Body $byte

        $jsonString = $response.choices[0].message.content.Trim()
        try
        {
            $parsedJson = $jsonString | ConvertFrom-Json
        }
        catch
        {
            Write-Error "Failed to parse JSON: $($_.Exception.Message) `nOriginal string: $jsonString"
            return
        }

        $outRule = $parsedJson.rule
        $outputs = $parsedJson.outputs
        
        if ($null -eq $outputs -or $outputs -isnot [array])
        {
            Write-Error "Failed to parse JSON.`nOriginal string: $jsonString"
            return
        }

        $length = @($outputs).Length
        if ($length -ne $in.Length)
        {
            Write-Warning "The number of input and output elements does not match. There are $($in.Length) input elements, while there are $($length) output elements."
            $length = [math]::Min($length, $in.Length)
        }

        $objs = 0..($length - 1) | ForEach-Object {
            [PSCustomObject]@{
                Input  = $in[$_].Trim()
                Output = $outputs[$_]
            }
        }

        if ($IncludeRule)
        {
            return [PSCustomObject]@{
                Rule        = [string]::IsNullOrEmpty($outRule) ? $Rule : $outRule
                StringPairs = $objs
            }
        }
        
        if ($IncludeInput)
        {
            if (-not [string]::IsNullOrEmpty($outRule))
            {
                Write-Host
                Write-Host "`tRule: " $outRule
            }
            $objs
            return
        }

        foreach ($o in $objs)
        {
            $o.Output
        }
        return
    }
}
