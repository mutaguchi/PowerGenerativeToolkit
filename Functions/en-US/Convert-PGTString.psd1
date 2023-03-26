@{Examples = @(
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