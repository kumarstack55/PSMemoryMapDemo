# PSMemoryMapDemo

MemoryMappedFile クラスで、別プロセスとデータを授受するデモです。

数万回程度のアクセスを試みると失敗するため、利用しないべき。
原因を特定できなかった。

特定できるまで、ファイルでアクセスしたほうがよさそう。

## テスト

```powershell
Invoke-Pester
```

## LICENSE

MIT
