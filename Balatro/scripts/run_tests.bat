@echo off
chcp 65001 >nul
echo ========================================
echo Balatro 测试运行脚本
echo ========================================
echo.

set GODOT_PATH=D:\tool\Godot_v4.2.2-stable_win64.exe

echo 检查 Godot 引擎...
if not exist "%GODOT_PATH%" (
    echo 错误: 未找到 Godot 引擎
    pause
    exit /b 1
)

echo ✓ Godot 引擎就绪
echo.

echo 选择测试类型:
echo   1. 手牌评估器测试 (test_hand_evaluator.gd)
echo   2. 随机系统测试 (test_random_system.gd)
echo   3. 进度管理器测试 (test_progress_manager.gd)
echo   4. 核心循环集成测试 (test_game_integration.gd)
echo   5. Steam集成测试 (test_steam_integration.gd)
echo   6. 全部测试
echo.

set /p CHOICE="请输入选项 (1-6): "

echo.
echo 正在启动测试...
echo ========================================

if "%CHOICE%"=="1" (
    "%GODOT_PATH%" --headless --script tests/test_hand_evaluator.gd --path "%~dp0"
) else if "%CHOICE%"=="2" (
    "%GODOT_PATH%" --headless --script tests/test_random_system.gd --path "%~dp0"
) else if "%CHOICE%"=="3" (
    "%GODOT_PATH%" --headless --script tests/test_progress_manager.gd --path "%~dp0"
) else if "%CHOICE%"=="4" (
    "%GODOT_PATH%" --headless --script tests/test_game_integration.gd --path "%~dp0"
) else if "%CHOICE%"=="5" (
    "%GODOT_PATH%" --headless --script tests/test_steam_integration.gd --path "%~dp0"
) else if "%CHOICE%"=="6" (
    echo 运行全部测试...
    "%GODOT_PATH%" --headless --script tests/test_hand_evaluator.gd --path "%~dp0"
    echo.
    "%GODOT_PATH%" --headless --script tests/test_random_system.gd --path "%~dp0"
    echo.
    "%GODOT_PATH%" --headless --script tests/test_game_integration.gd --path "%~dp0"
) else (
    echo 无效选项
    exit /b 1
)

echo.
echo ========================================
echo 测试完成
pause
