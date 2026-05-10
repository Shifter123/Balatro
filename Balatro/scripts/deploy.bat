@echo off
chcp 65001 >nul
echo ========================================
echo Balatro 部署向导
echo ========================================
echo.

echo 此脚本将帮助你在 Windows 上部署并测试 Balatro 项目
echo.

echo [1/4] 检查 Godot 引擎...
set GODOT_PATH=D:\tool\Godot_v4.2.2-stable_win64.exe

if not exist "%GODOT_PATH%" (
    echo 警告: 默认路径未找到 Godot 引擎
    echo.
    echo 请选择:
    echo   1. 指定 Godot 路径
    echo   2. 下载 Godot 4.2.2
    echo.
    set /p OPT="请输入选项 (1-2): "
    if "%OPT%"=="2" (
        start https://github.com/godotengine/godot/releases/tag/4.2.2-stable
    )
    set /p GODOT_PATH="请输入 Godot.exe 完整路径: "
)

if exist "%GODOT_PATH%" (
    echo ✓ 找到 Godot 引擎
) else (
    echo 错误: Godot 引擎不存在
    pause
    exit /b 1
)

echo.
echo [2/4] 验证项目文件...
if exist "project.godot" (
    echo ✓ 项目文件完整
) else (
    echo ✗ project.godot 不存在，请确保在项目根目录运行
    pause
    exit /b 1
)

echo.
echo [3/4] 可用操作:
echo   1. 同步最新代码 (git pull)
echo   2. 运行游戏
echo   3. 运行测试
echo   4. 全部执行
echo.

set /p ACTION="请输入选项 (1-4): "

if "%ACTION%"=="1" (
    echo 同步代码...
    git pull origin dev
) else if "%ACTION%"=="2" (
    echo 启动游戏...
    call scripts\run_game.bat
) else if "%ACTION%"=="3" (
    echo 运行测试...
    call scripts\run_tests.bat
) else if "%ACTION%"=="4" (
    echo 同步代码...
    git pull origin dev
    echo.
    echo 启动游戏...
    call scripts\run_game.bat
) else (
    echo 无效选项
)

echo.
echo ========================================
echo 部署向导完成
pause
