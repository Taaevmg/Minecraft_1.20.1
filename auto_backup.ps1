# auto_backup.ps1 - Авто-коммит Minecraft сервера

$ServerDir = "C:\MinecraftServer"
$BackupDir = "C:\MinecraftBackups"
$GitRepo = "C:\MinecraftServer"
$Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "=== Начинаем backup Minecraft сервера ===" -ForegroundColor Green

# 1. Создаем backup директорию
New-Item -ItemType Directory -Force -Path $BackupDir | Out-Null

# 2. Создаем архив backup
$BackupFile = "$BackupDir\minecraft_$(Get-Date -Format 'yyyyMMdd_HHmmss').zip"
try {
    Compress-Archive -Path "$ServerDir\world" -DestinationPath $BackupFile -Force
    Write-Host "✓ Backup создан: $BackupFile" -ForegroundColor Green
} catch {
    Write-Host "✗ Ошибка создания архива: $_" -ForegroundColor Red
}

# 3. Инициализируем git если нужно
if (-not (Test-Path "$GitRepo\.git")) {
    Write-Host "Инициализируем git репозиторий..." -ForegroundColor Yellow
    Set-Location $GitRepo
    git init
    git config user.email "minecraft@server"
    git config user.name "Minecraft Server"
    "# Minecraft Server Backup" | Out-File -FilePath "README.md" -Encoding UTF8
}

# 4. Добавляем и коммитим
Set-Location $GitRepo
git add .
git commit -m "Auto-backup: $Date" --allow-empty

# 5. Логируем
$LogMessage = "$Date - Backup created: $BackupFile"
$LogMessage | Out-File -FilePath "$BackupDir\backup.log" -Append
Write-Host $LogMessage -ForegroundColor Cyan

# 6. Удаляем старые бекапы (храним 30 последних)
$BackupFiles = Get-ChildItem "$BackupDir\minecraft_*.zip" | Sort-Object LastWriteTime -Descending
if ($BackupFiles.Count -gt 30) {
    $OldFiles = $BackupFiles | Select-Object -Skip 30
    $OldFiles | Remove-Item -Force
    Write-Host "✓ Удалено старых backup: $($OldFiles.Count)" -ForegroundColor Yellow
}

Write-Host "=== Backup завершен! ===" -ForegroundColor Green
Write-Host "Файл: $BackupFile"
Write-Host "Коммит: Auto-backup: $Date"