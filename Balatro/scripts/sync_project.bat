@echo off
chcp 65001 >nul
echo ========================================
echo Balatro 项目同步脚本
echo ========================================
echo.

cd /d "%~dp0"

echo [1/3] 检查 Git 状态...
git status >nul 2>&1
if errorlevel 1 (
    echo 错误: 不是 Git 仓库或 Git 未安装
    pause
    exit /b 1
)

echo [2/3] 拉取最新代码...
git fetch origin
git pull origin dev

if errorlevel 1 (
    echo 错误: 拉取代码失败
    pause
    exit /b 1
)

echo [3/3] 检查项目完整性...
if exist "project.godot" (
    echo ✓ project.godot 存在
) else (
    echo ✗ project.godot 不存在
    pause
    exit /b 1
)

if exist "src\scripts\game_manager.gd" (
    echo ✓ 核心脚本存在
) else (
    echo ✗ 核心脚本缺失
    pause
    exit /b 1
)

echo.
echo ========================================
echo 同步完成！
echo ========================================
pause
