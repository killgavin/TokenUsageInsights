param(
    [string]$InstallDir = "$env:LOCALAPPDATA\TokenUsageInsights",
    [string]$BinDir = "$HOME\bin"
)

$ErrorActionPreference = "Stop"
$AppName = "token-usage-insights"
$Shim = Join-Path $BinDir "$AppName.cmd"

Write-Host "開始卸載 Token 戰情室 (Windows)..."
Write-Host "--------------------------------"

# 1. 檢查並中止可能正在執行的行程，避免檔案鎖定
$RunningProcesses = Get-Process -Name $AppName -ErrorAction SilentlyContinue
if ($RunningProcesses) {
    Write-Host "偵測到 $AppName 正在執行，正在停止行程..."
    Stop-Process -Name $AppName -Force
    Start-Sleep -Seconds 1
}

# 2. 移除 Executable shim (命令捷徑)
if (Test-Path $Shim) {
    try {
        Remove-Item -Force $Shim
        Write-Host "已移除命令捷徑: $Shim"
    } catch {
        Write-Warning "無法移除 $Shim，請確認是否有權限或檔案被鎖定。"
    }
}

# 3. 移除安裝主目錄 (包含 static、shell、scripts、pricing.csv 等所有檔案)
if (Test-Path $InstallDir) {
    try {
        Remove-Item -Recurse -Force $InstallDir
        Write-Host "已成功移除安裝目錄: $InstallDir"
    } catch {
        Write-Warning "移除安裝目錄時發生錯誤。"
        Write-Error $_
    }
} else {
    Write-Host "未發現安裝目錄，跳過。 ($InstallDir)"
}

# 4. 檢查並清理空目錄 (優化判斷邏輯)
if (Test-Path $BinDir) {
    $BinDirItems = Get-ChildItem -Path $BinDir -ErrorAction SilentlyContinue
    # 確保不論回傳 $null 或是空陣列，都能正確判定為空目錄
    if ($null -eq $BinDirItems -or $BinDirItems.Count -eq 0) {
        try {
            Remove-Item -Force $BinDir
            Write-Host "偵測到 $BinDir 已無其他檔案，已一併將其移除。"
        } catch {
            # 避免因其他程序剛好讀取該目錄而拋錯
            Write-Warning "嘗試移除空目錄 $BinDir 時失敗。"
        }
    }
}

Write-Host "--------------------------------"
Write-Host "Token 戰情室 卸載程序完成。"
