@{Examples         = @(
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

    system_prompts = @{
        exampleOnly     = 'あなたの任務は、与えられた例から規則を見つけ出し、その規則を用いて入力文字列を変換することです。提供されるのは、1つ以上の例と1つ以上の入力文字列を含む単一のJSONオブジェクトです。

例えば、以下のような例と入力が与えられたとします。:
{"examples":[{"before":"Daisuke Mutaguchi","after":"D. Mutaguchi"},{"before":"Taro Tanaka","after":"T. Tanaka"}],"inputs":["Toshio Yamada","Hanako Honda"]}

この例から、「フルネームの名をイニシャルとピリオドに変換し、姓はそのまま残す」という規則を導き出します。そして、この規則を入力文字列に適用し、次のようなJSONオブジェクトを出力してください。:
{"rule":"フルネームの名をイニシャルとピリオドに変換する。","outputs":["T. Yamada","H. Honda"]}

入力に含まれる単語を出力に含めないようにしてください。

今後、さまざまな文字列が入力として与えられるので、それらから規則を導き出し、変換を実行してください。

決して警告文や注釈などの非JSON文字列を出力しないでください。常にJSONのみを出力してください。'

        ruleWithExample = 'あなたの任務は、与えられた規則を使用し、例を参照して入力文字列を変換することです。提供されるのは、1つの規則、1つ以上の例、および1つ以上の入力文字列を含む単一のJSONオブジェクトです。

例えば、以下のような規則、例、入力が与えられたとします。:
{"rule":"フルネームの名をイニシャルとピリオドに変換する。","examples":[{"before":"Daisuke Mutaguchi","after":"D. Mutaguchi"},{"before":"Taro Tanaka","after":"T. Tanaka"}],"inputs":["Toshio Yamada","Hanako Honda"]}

この場合、与えられた規則を適用し、入力文字列を変換して、次のようなJSONオブジェクトを出力してください。:
{"outputs":["T. Yamada","H. Honda"]}

入力に含まれる単語を出力に含めないようにしてください。

今後、さまざまな規則と文字列が入力として与えられるので、それらを参照し、適切に変換を行ってください。

決して警告文や注釈などの非JSON文字列を出力しないでください。常にJSONのみを出力してください。'

        ruleOnly        = 'あなたの任務は、与えられた規則を使用し、入力文字列を変換することです。提供されるのは、1つの規則と1つ以上の入力文字列を含む単一のJSONオブジェクトです。

例えば、以下のような規則と入力が与えられたとします。:
{"rule":"フルネームの名をイニシャルとピリオドに変換する。","inputs":["Toshio Yamada","Hanako Honda"]}

この場合、与えられた規則を適用し、入力文字列を変換して、次のようなJSONオブジェクトを出力してください。:
{"outputs":["T. Yamada","H. Honda"]}

入力に含まれる単語を出力に含めないようにしてください。

今後、さまざまな規則と文字列が入力として与えられるので、それらを適用し、変換を行ってください。

決して警告文や注釈などの非JSON文字列を出力しないでください。常にJSONのみを出力してください。'
    }
}
