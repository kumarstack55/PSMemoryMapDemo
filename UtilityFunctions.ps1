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
    $createOrOpenCapacity = $global:DataBytes.Length + 1
    $memoryMappedFile = $MemoryMappedFileClass::CreateOrOpen($MapName, $createOrOpenCapacity)

    # CreateViewStream() は使わない。
    # CreateViewStream() は ローカル変数で viewStream を扱うときに、
    # 稀にマップト・ファイルを作れないように見えるため。
    $viewAccessor = $memoryMappedFile.CreateViewAccessor()
    $viewAccessor.WriteArray(0, $DataBytes, 0, $DataBytes.Length)
    $viewAccessor.Dispose()
}

function Get-MemoryMappedFileContentAsBytes {
    param([Parameter(Mandatory)][string]$MapName)

    $MemoryMappedFileClass = [System.IO.MemoryMappedFiles.MemoryMappedFile]
    $memoryMappedFile = $MemoryMappedFileClass::OpenExisting($mapName)
    $viewAccessor = $memoryMappedFile.CreateViewAccessor()
    $capacity = $viewAccessor.Capacity
    $bufferLength = $capacity
    $buffer = New-Object byte[] $bufferLength
    $viewAccessor.ReadArray(0, $buffer, 0, $buffer.Length) | Out-Null
    $viewAccessor.Dispose()
    return $buffer
}

function Invoke-NewOrUpdateMemoryMappedFileContentWithExclusiveControl {
    param(
        [Parameter(Mandatory)][System.Threading.Mutex]$Mutex,
        [Parameter(Mandatory)][string]$MapName,
        [Parameter(Mandatory)][byte[]]$DataBytes
    )

    try {
        $Mutex.WaitOne() | Out-Null
        Invoke-NewOrUpdateMemoryMappedFileContent -MapName $MapName -DataBytes $DataBytes
    } catch {
        throw $_
    } finally {
        $Mutex.ReleaseMutex()
    }
}

function Get-MemoryMappedFileContentAsBytesWithExclusiveControl {
    param(
        [Parameter(Mandatory)][System.Threading.Mutex]$Mutex,
        [Parameter(Mandatory)][string]$MapName
    )

    $buffer = $null
    try {
        $Mutex.WaitOne() | Out-Null
        $buffer = Get-MemoryMappedFileContentAsBytes -MapName $MapName
    } catch {
        throw $_
    } finally {
        $Mutex.ReleaseMutex()
    }
    return $buffer
}

#function Invoke-StartSleep {
#    param([Parameter(Mandatory)][int]$Seconds)
#
#    Write-Host "Sleeping..."
#    Start-Sleep $Seconds
#}
