. (Join-Path $PSScriptRoot "vars.ps1")
. (Join-Path $PSScriptRoot "UtilityFunctions.ps1")

$nowLocaltime = Get-Date

# オブジェクトに格納する時刻を UTC にする。
# JSON変換時に、タイムゾーンの情報が保存されないために、
# メモリ・マップト・ファイルをもとにデータを読む際に、時刻のズレが発生する。
# これを回避するために UTC で格納する。
$now = $nowLocaltime.ToUniversalTime()

$dataPso = [pscustomobject]@{
    "key1"="value1"
    "key2"="あ"
    "LastWriteTime"=$now
}

$dataPso | Write-Host

$dataJson = $dataPso | ConvertTo-Json

$dataJson | Write-Host

$dataBytes = [Text.Encoding]::UTF8.GetBytes($dataJson)

$mutex = Get-Mutex -MutexName $MutexName
Invoke-NewOrUpdateMemoryMappedFileContentSafely -Mutex $mutex -MapName $MapName -DataBytes $dataBytes
