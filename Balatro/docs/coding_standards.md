# GDScript编码规范

## 1. 文件命名

- 场景文件使用小写下划线命名：`main_menu.tscn`, `card_display.tscn`
- 脚本文件使用小写下划线命名：`card_manager.gd`, `battle_system.gd`
- 资源文件使用小写下划线命名：`card_back.png`, `coin_sound.wav`
- 常量文件使用全大写下划线命名：`constants.gd`

## 2. 节点命名

- 根节点：使用有意义的名称，如 `Card`, `BattleField`, `MainMenu`
- 子节点：使用 PascalCase：`CardSprite`, `PlayButton`
- 匿名节点使用描述性名称：`Timer`, `CollisionShape2D` → `StunTimer`, `Hitbox/CollisionShape2D`

## 3. 变量命名

### 3.1 局部变量
- 使用小写下划线命名：`player_score`, `current_hand`
- 布尔变量使用 is/has/can 前缀：`is_active`, `has_won`, `can_play`

### 3.2 成员变量
- 使用小写下划线命名：`health`, `score`
- 私有成员使用下划线前缀：`_cache`, `_is_initialized`

### 3.3 常量
- 使用全大写下划线命名：`MAX_HEALTH`, `DEFAULT_SEED`
- 枚举值使用 PascalCase：`Suit.HEARTS`, `CardRank.ACE`

## 4. 函数命名

- 使用小写下划线命名：`get_card()`, `calculate_score()`
- 信号函数使用 `_on_` 前缀：`_on_button_pressed()`
- 虚拟函数保留下划线前缀：`_ready()`, `_process()`

## 5. 类结构

```gdscript
class_name ClassName
extends BaseClass

signal changed(new_value)

const DEFAULT_VALUE: int = 10

var _private_var: int = 0
var public_var: String = ""

func _ready() -> void:
    pass

func public_method() -> void:
    pass

func _private_method() -> void:
    pass
```

## 6. 类型注解

- 所有变量和函数参数必须声明类型：`var health: int = 100`
- 函数返回值必须声明类型：`func get_score() -> int:`
- 使用 `void` 表示无返回值：`func process_input() -> void:`

## 7. 代码格式

- 使用 Tab 缩进
- 每行不超过 100 字符
- 操作符前后添加空格：`a + b`, `x == y`
- 字典和数组声明每行一个元素

```gdscript
var items: Array = [
    "item1",
    "item2",
    "item3"
]
```

## 8. 注释规范

- 使用 `#` 符号添加注释
- 公共 API 添加文档注释
- 复杂逻辑添加行内说明

```gdscript
## 获取指定类型的卡牌
## [param suit] 花色
## [param rank] 点数
func get_card(suit: int, rank: int) -> Card:
    pass
```

## 9. 错误处理

- 使用 `assert()` 进行开发期验证
- 使用 `push_error()` 记录运行时错误
- 返回值使用 `Result` 类型模式处理错误

## 10. 性能注意事项

- 避免在 `_process()` 中分配内存
- 使用对象池管理频繁创建的对象
- 缓存频繁访问的节点引用
- 使用 `@export` 替代运行时查找节点
