@{Examples = @(
        @{
            rule     = "漢字に変換する"
            examples = @(
                @{before = "おなかすいた。"; after = "お腹空いた。" }
            )
            answers  = @(
                @{before = "あさがきた。"; after = "朝が来た。" },
                @{before = "ねむいですね。"; after = "眠いですね。" },
                @{before = "たのしいね"; after = "楽しいね。" }
            )
        },
        @{
            rule     = "英訳する"
            examples = @(
                @{before = "りんご"; after = "apple" },
                @{before = "パイナップル"; after = "pineapple" }
            )
            answers  = @(
                @{before = "バナナ"; after = "banana" }
            )
        },
        @{
            rule     = "説明文を生成する"
            examples = @(
                @{before = "折り紙"; after = "紙を折って作る様々な形の日本の伝統的な芸術" },
                @{before = "寿司"; after = "魚や海老、貝などの魚介類を酢飯と組み合わせた日本料理" }
            )
            answers  = @(
                @{before = "盆栽"; after = "樹木を小型の鉢に植えて育て、美しい姿を楽しむ日本の伝統的な趣味" },
                @{before = "和紙"; after = "植物の繊維を原料とした日本の伝統的な紙" },
                @{before = "茶道"; after = "茶を点てて楽しむ、日本の伝統的な文化と精神性を兼ね備えた芸術" }
            )
        },
        @{
            rule     = "PowerShell関数を作成する"
            examples = @(
                @{before = "ファイル名に日付を付ける"; after = 'function Add-DateToFileName {
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
                @{before = "カレントフォルダ内で画像ファイルのサイズを合計する"; after = 'function Get-PictureFileSize {
Get-ChildItem | Where-Object {{$_.Extension -in ".png",".gif",".jpg"}}|Measure-Object -Property Length -Sum|Select-Object -ExpandProperty "Sum"
}'
                }
            )
        }
    )
}
