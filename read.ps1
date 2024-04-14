. (Join-Path $PSScriptRoot "vars.ps1")
. (Join-Path $PSScriptRoot "UtilityFunctions.ps1")

$mutex = Get-Mutex -MutexName $MutexName
$buffer = Get-MemoryMappedFileContentAsBytesSafely -Mutex $mutex $MapName
if ($null -ne $buffer) {
    $dataStringWithZeros = [Text.Encoding]::UTF8.GetString($buffer)
    $dataString = $dataStringWithZeros.Trim([char]0)

    $dataString | Write-Host

    $pso = $dataString | ConvertFrom-Json

    $pso | Write-Host

    $lastWriteTimeUtc = $pso.LastWriteTime
    $lastWriteTime = $lastWriteTimeUtc.ToLocalTime()
    "lastWriteTime: {0}" -f $lastWriteTime
}
