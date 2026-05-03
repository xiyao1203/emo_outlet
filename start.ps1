# ============================================================
# 情绪出口 (Emo Outlet) — 一键启动脚本
# 同时启动后端 (FastAPI) + 前端 (Flutter)
# ============================================================

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "     情绪出口 Emo Outlet — 一键启动" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

$ROOT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$BACKEND_DIR = Join-Path $ROOT_DIR "emo_outlet_api"
$FRONTEND_DIR = Join-Path $ROOT_DIR "emo_outlet_app"

# ── 1. 启动后端 ──────────────────────────────────────────
Write-Host "[1/2] 启动后端服务 (FastAPI)..." -ForegroundColor Yellow
Write-Host "      端口: 8686" -ForegroundColor Gray
Write-Host "      API文档: http://localhost:8686/docs" -ForegroundColor Gray

$BACKEND_CMD = "uvicorn app.main:app --reload --host 0.0.0.0 --port 8686"

Start-Process -WindowStyle Normal -FilePath "powershell" -ArgumentList @(
    "-NoExit",
    "-Command",
    "cd '$BACKEND_DIR'; Write-Host '=== 情绪出口 后端服务 ===' -ForegroundColor Cyan; Write-Host "Port: 8686  Docs: http://localhost:8686/docs" -ForegroundColor Gray; $BACKEND_CMD"
)

# 等后端启动一下
Start-Sleep -Seconds 3

# ── 2. 启动前端 ──────────────────────────────────────────
Write-Host "[2/2] 启动前端 (Flutter)..." -ForegroundColor Yellow

# 检查 Flutter 是否已安装
$FLUTTER_CMD = Get-Command "flutter" -ErrorAction SilentlyContinue

if ($null -eq $FLUTTER_CMD) {
    Write-Host "      ⚠ Flutter SDK 未安装，跳过前端启动" -ForegroundColor Red
    Write-Host "      $ 安装 Flutter 后, 手动运行:" -ForegroundColor Gray
    Write-Host "      cd $FRONTEND_DIR" -ForegroundColor Gray
    Write-Host "      flutter run -d chrome --web-port=5177" -ForegroundColor Gray
} else {
    Write-Host "      端口: 5177 (Web调试)" -ForegroundColor Gray
    Write-Host "      检测到Flutter SDK, 正在启动..." -ForegroundColor Green

    Start-Process -WindowStyle Normal -FilePath "powershell" -ArgumentList @(
        "-NoExit",
        "-Command",
        "cd '$FRONTEND_DIR'; Write-Host '=== 情绪出口 前端服务 ===' -ForegroundColor Cyan; flutter run -d chrome --web-port=5177"
    )
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host " 启动完成！" -ForegroundColor Green
Write-Host " 后端: http://localhost:8686" -ForegroundColor Green
Write-Host " API文档: http://localhost:8686/docs" -ForegroundColor Green
if ($null -ne $FLUTTER_CMD) {
    Write-Host " 前端: http://localhost:5177" -ForegroundColor Green
}
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "按任意键关闭本窗口..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
