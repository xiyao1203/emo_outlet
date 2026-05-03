@echo off
chcp 65001 >nul
title 情绪出口 - 一键启动

echo ============================================
echo     情绪出口 Emo Outlet - 一键启动
echo ============================================
echo.

:: ── 后端 ──────────────────────────────────────
echo [1/2] 启动后端服务 (FastAPI) ^| 端口: 8686
echo        API文档: http://localhost:8686/docs

start "情绪出口-后端" cmd /c "cd /d "%~dp0emo_outlet_api" && title 情绪出口-后端 && echo === 情绪出口 后端服务 === && echo Port: 8686  Docs: http://localhost:8686/docs && uvicorn app.main:app --reload --host 0.0.0.0 --port 8686"

timeout /t 3 /nobreak >nul

:: ── 前端 ──────────────────────────────────────
echo [2/2] 启动前端 (Flutter) ^| 端口: 5177

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo        ^>^>^> Flutter SDK 未安装，跳过前端启动
    echo        ^>^>^> 安装 Flutter 后, 手动运行:
    echo            cd "%~dp0emo_outlet_app"
    echo            flutter run -d chrome --web-port=5177
) else (
    echo        检测到 Flutter SDK, 正在启动...
    start "情绪出口-前端" cmd /c "cd /d "%~dp0emo_outlet_app" && title 情绪出口-前端 && echo === 情绪出口 前端服务 === && flutter run -d chrome --web-port=5177"
)

echo.
echo ============================================
echo  启动完成！
echo  后端: http://localhost:8686
echo  API文档: http://localhost:8686/docs
if %errorlevel% equ 0 (
    echo  前端: http://localhost:5177
)
echo ============================================
echo.
pause
