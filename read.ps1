$commonPath = Join-Path $PSScriptRoot "common.ps1"
. $commonPath

$initiallyOwned = $false
$mutex = [System.Threading.Mutex]::new($initiallyOwned, $MutexName)

$MemoryMappedFileClass = [System.IO.MemoryMappedFiles.MemoryMappedFile]

$mutex.WaitOne() | Out-Null
$memoryMappedFile = $MemoryMappedFileClass::OpenExisting($MapName)
$viewAccessor = $memoryMappedFile.CreateViewAccessor()
$capacity = $viewAccessor.Capacity
"capacity: {0}" -f $capacity
$bufferLength = $capacity
$buffer = New-Object byte[] $bufferLength
$viewAccessor.ReadArray(0, $buffer, 0, $buffer.Length) | Out-Null

Start-Sleep 5

$mutex.ReleaseMutex()

$dataStringWithZeros = [Text.Encoding]::ASCII.GetString($buffer)
$dataString = $dataStringWithZeros.Trim([char]0)
$pso = $dataString | ConvertFrom-Json
$pso

$viewAccessor.Dispose()
