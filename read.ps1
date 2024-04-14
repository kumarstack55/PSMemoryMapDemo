$commonPath = Join-Path $PSScriptRoot "common.ps1"
. $commonPath

$mutex = Get-Mutex -MutexName $MutexName
$buffer = $null
try {
    Write-Warning "calling mutex.WaitOne()..."
    $mutex.WaitOne() | Out-Null

    $buffer = Get-MemoryMappedFileContentAsBytes -MapName $MapName
} catch {
    throw $_
} finally {
    Write-Warning "calling mutex.ReleaseMutex()..."
    $mutex.ReleaseMutex()
}

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
