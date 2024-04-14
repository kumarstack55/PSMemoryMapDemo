$MapName = "TestMapName1"
$MutexName = "Global\TestMutexName1"

function Get-Mutex {
    param([Parameter(Mandatory)][string]$MutexName)

    $initiallyOwned = $false
    $mutex = [System.Threading.Mutex]::new($initiallyOwned, $MutexName)
    return $mutex
}

function Invoke-NewOrUpdateMemoryMappedFileContent {
    param(
        [Parameter(Mandatory)][string]$MapName,
        [Parameter(Mandatory)][byte[]]$DataBytes
    )

    $MemoryMappedFileClass = [System.IO.MemoryMappedFiles.MemoryMappedFile]

    $capacity = $DataBytes.Length + 1
    Write-Warning ("capacity: {0}" -f $capacity)

    $memoryMappedFile = $MemoryMappedFileClass::CreateOrOpen($MapName, $capacity)
    $viewStream = $memoryMappedFile.CreateViewStream()
    $viewStream.Write($DataBytes, 0, $DataBytes.Length)
    $viewStream.WriteByte([byte]0)
    $viewStream.Dispose()

    return $null
}

function Get-MemoryMappedFileContentAsBytes {
    param([Parameter(Mandatory)][string]$MapName)

    $buffer = $null
    $viewAccessor = $null
    try {
        $MemoryMappedFileClass = [System.IO.MemoryMappedFiles.MemoryMappedFile]
        $memoryMappedFile = $MemoryMappedFileClass::OpenExisting($MapName)
        $viewAccessor = $memoryMappedFile.CreateViewAccessor()

        $capacity = $viewAccessor.Capacity
        Write-Warning ("capacity: {0}" -f $capacity)

        $bufferLength = $capacity
        $buffer = New-Object byte[] $bufferLength
        $viewAccessor.ReadArray(0, $buffer, 0, $buffer.Length) | Out-Null
    } catch {
        throw $_
    } finally {
        if ($null -ne $viewAccessor) {
            $viewAccessor.Dispose()
        }
    }
    return $buffer
}

function Invoke-StartSleep {
    param([Parameter(Mandatory)][int]$Seconds)

    Write-Host "Sleeping..."
    Start-Sleep $Seconds
}
