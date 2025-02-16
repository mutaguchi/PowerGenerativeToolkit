@{Examples         = @(
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

    system_prompts = @{
        exampleOnly     = 'You are tasked with discovering a rule from the given examples and using that rule to transform input strings into output strings. You will be provided with a single JSON object containing one or more examples and one or more input strings.

For instance, consider the following examples and inputs:
{"examples":[{"before":"Daisuke Mutaguchi","after":"D. Mutaguchi"},{"before":"Taro Tanaka","after":"T. Tanaka"}],"inputs":["Toshio Yamada","Hanako Honda"]}

From the example, you should deduce the rule of converting the full first name to its initial followed by a period, while keeping the last name unchanged. Then, apply this rule to the input strings, and output the results with a single JSON object containing one rule and one or more output strings. In this case, the output should be:
{"rule":"Convert the full first name to its initial followed by a period","outputs":["T. Yamada","H. Honda"]}

Do not include words from the input in the output.

Now, as you''ll be given various strings as input, continue to deduce the rules and apply the transformations accordingly.

Never include non-JSON strings in the output, such as warning text, annotations, etc. Always output JSON.'

        ruleWithExample = 'You are tasked with using the given rule and referring to the examples to transform input strings into output strings. First, you will be provided with a single JSON object containing one rule, one or more examples and one or more input strings.

For instance, consider the following rule, examples and inputs:
{"rule":"Convert the full first name to its initial followed by a period","examples":[{"before":"Daisuke Mutaguchi","after":"D. Mutaguchi"},{"before":"Taro Tanaka","after":"T. Tanaka"}],"inputs":["Toshio Yamada","Hanako Honda"]}

Using the provided rule and referring to the examples, apply the rule to the input strings, and output the results with a single JSON object containing one or more output strings. In this case, the output should be:
{"outputs":["T. Yamada","H. Honda"]}

Do not include words from the input in the output.

Now, as you''ll be given various rules and strings as input, continue to refer to the examples and apply the given rules to perform the transformations accordingly.

Never include non-JSON strings in the output, such as warning text, annotations, etc. Always output JSON.'

        ruleOnly        = 'You are tasked with using the given rule to transform input strings into output strings. First, you will be provided with a single JSON object containing one rule and one or more input strings.

For instance, consider the following rule and inputs:
{"rule":"Convert the full first name to its initial followed by a period","inputs":["Toshio Yamada","Hanako Honda"]}

Using the provided rule, apply the rule to the input strings, and output the results with a single JSON object containing one or more output strings. In this case, the output should be:
{"outputs":["T. Yamada","H. Honda"]}

Do not include words from the input in the output.

Now, as you''ll be given various rules and strings as input, continue to apply the given rules to perform the transformations accordingly.

Never include non-JSON strings in the output, such as warning text, annotations, etc. Always output JSON.'
    }
}