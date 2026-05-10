@echo off
chcp 65001 >nul
echo ========================================
echo Balatro Windows 启动脚本
echo ========================================
echo.

set GODOT_PATH=D:\tool\Godot_v4.2.2-stable_win64.exe

echo 正在检查 Godot 引擎...
if not exist "%GODOT_PATH%" (
    echo 警告: 未找到 Godot 引擎: %GODOT_PATH%
    echo.
    echo 请确认 Godot 4.2.2 已安装，或修改脚本中的 GODOT_PATH 变量
    echo 下载地址: https://github.com/godotengine/godot/releases/tag/4.2.2-stable
    echo.
    set /p USER_GODOT="请输入 Godot 路径，或按 Enter 退出: "
    if "%USER_GODOT%"=="" exit /b 1
    set GODOT_PATH=%USER_GODOT%
)

echo ✓ 找到 Godot: %GODOT_PATH%
echo.

echo 正在启动 Balatro...
echo ========================================
echo.

"%GODOT_PATH%" --path "%~dp0"

echo.
echo ========================================
echo 游戏已退出
pause
