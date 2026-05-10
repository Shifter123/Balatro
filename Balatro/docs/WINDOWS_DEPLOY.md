# Balatro Windows 部署指南

## 环境要求

| 项目 | 要求 |
|------|------|
| 操作系统 | Windows 10/11 (64-bit) |
| Godot 引擎 | 4.2.2 Stable |
| 内存 | 4GB+ |
| 磁盘空间 | 500MB+ |

## 快速开始

### 1. 克隆项目

```cmd
git clone <your-repo-url>
cd Balatro
```

### 2. 配置 Godot 路径

编辑 `scripts\run_game.bat`，确认 Godot 路径正确：

```batch
set GODOT_PATH=D:\tool\Godot_v4.2.2-stable_win64.exe
```

### 3. 运行游戏

**方式一：双击脚本运行**
```cmd
scripts\deploy.bat
```

**方式二：直接运行**
```cmd
scripts\run_game.bat
```

**方式三：使用 Godot 打开**
```
双击 project.godot 文件
```

## 脚本说明

| 脚本 | 用途 |
|------|------|
| `deploy.bat` | 一站式部署向导 |
| `run_game.bat` | 启动游戏 |
| `run_tests.bat` | 运行测试 |
| `sync_project.bat` | 同步最新代码 |

## 测试游戏

### 运行所有测试
```cmd
scripts\run_tests.bat
```

### 可用测试列表

1. 手牌评估器测试
2. 随机系统测试
3. 进度管理器测试
4. 核心循环集成测试
5. Steam集成测试

## 常见问题

### Q: Godot 未找到
**A:** 确认 `run_game.bat` 中的 `GODOT_PATH` 指向正确的 Godot 可执行文件路径

### Q: 出现编译错误
**A:** 确保 Godot 版本为 4.2.2，非 4.6.2

### Q: 测试无法运行
**A:** 使用 `--headless` 模式运行，确认项目文件完整

### Q: 如何更新代码
```cmd
cd Balatro
git pull origin dev
```

## Godot 下载地址

- 官网：https://godotengine.org/download/windows
- GitHub：https://github.com/godotengine/godot/releases/tag/4.2.2-stable

## Steam 功能测试

Steam 功能需要以下条件：
1. Steam 客户端已安装
2. Steam API 已配置
3. 有效的 App ID

在本地测试时，Steam 集成会使用离线模式。
