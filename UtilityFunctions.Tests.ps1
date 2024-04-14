BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "UtilityFunctions" {
    Context "Invoke-NewOrUpdateMemoryMappedFileContentSafely" {
        It "書いたデータを読める。" {
            $dataString = "data1"

            $dataBytesWithoutZero = [Text.Encoding]::UTF8.GetBytes($dataString)

            # 末尾がゼロの byte[] を得る。
            $dataBytesLength = $dataBytesWithoutZero.Length + 1
            $dataBytes = New-Object byte[] $dataBytesLength
            [System.Buffer]::BlockCopy($dataBytesWithoutZero, 0, $dataBytes, 0, $dataBytesWithoutZero.Length)

            $mutexNameGuid = [guid]::NewGuid()
            $mutexName = $mutexNameGuid.ToString()
            $mutex = Get-Mutex -MutexName $mutexName

            foreach ($count in 1..10000) {
                $mapNameGuid = [guid]::NewGuid()
                $mapName = "{0}" -f $mapNameGuid.ToString()

                Invoke-NewOrUpdateMemoryMappedFileContentWithExclusiveControl -Mutex $mutex -MapName $mapName -DataBytes $dataBytes
                $buffer = Get-MemoryMappedFileContentAsBytesWithExclusiveControl -Mutex $mutex -MapName $mapName

                $dataStringWithZeros = [Text.Encoding]::UTF8.GetString($buffer)
                $dataString2 = $dataStringWithZeros.Trim([char]0)

                $dataString2 | Should -Be "data1"
            }

            $mutex.Close()
        }
    }
}
