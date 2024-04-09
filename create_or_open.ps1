$commonPath = Join-Path $PSScriptRoot "common.ps1"
. $commonPath

$now = Get-Date -UFormat "%s"

$dataPso = [pscustomobject]@{
    "key1"="value1"
    "key2"=$now
}

$dataJson = $dataPso | ConvertTo-Json
$dataBytes = [Text.Encoding]::ASCII.GetBytes($dataJson)

$MemoryMappedFileClass = [System.IO.MemoryMappedFiles.MemoryMappedFile]
$capacity = $dataBytes.Length
"capacity: {0}" -f $capacity

$initiallyOwned = $false
$mutex = [System.Threading.Mutex]::new($initiallyOwned, $MutexName)

$mutex.WaitOne() | Out-Null
$memoryMappedFile = $MemoryMappedFileClass::CreateOrOpen($MapName, $capacity)
$viewAccessor = $memoryMappedFile.CreateViewAccessor()
$viewAccessor.WriteArray(0, $dataBytes, 0, $dataBytes.Length)
$viewAccessor.Dispose()

Start-Sleep 5

$mutex.ReleaseMutex()

