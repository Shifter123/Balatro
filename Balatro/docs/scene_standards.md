# Scene Organization Standards

## Overview

This document defines how scenes should be organized in the Balatro project.

## Scene Directory Structure

```
src/scenes/
├── main/
│   ├── main_menu.tscn
│   ├── settings_menu.tscn
│   └── pause_menu.tscn
├── battle/
│   ├── battle_field.tscn
│   ├── hand_area.tscn
│   ├── card_slot.tscn
│   └── score_display.tscn
├── cards/
│   ├── playing_card.tscn
│   ├── joker_card.tscn
│   └── card_container.tscn
├── shop/
│   ├── shop_screen.tscn
│   ├── shop_item_slot.tscn
│   └── shop_item_button.tscn
├── ui/
│   ├── hud.tscn
│   ├── button.tscn
│   ├── progress_bar.tscn
│   └── tooltip.tscn
└── common/
    ├── animated_sprite.tscn
    └── transition_effect.tscn
```

## Node Naming Conventions

### Scene Root
- Name should match file name: `main_menu.tscn` → `MainMenu` root node
- Attach script if scene has logic

### UI Nodes
- Buttons: `PlayButton`, `ContinueButton`, `BackButton`
- Labels: `TitleLabel`, `ScoreLabel`, `DescriptionLabel`
- Containers: `ButtonContainer`, `CardContainer`

### Game Objects
- Cards: `PlayingCard`, `JokerSlot`
- Characters: `PlayerArea`, `EnemyArea`

## Scene Composition Guidelines

### 1. Single Responsibility
Each scene should represent one cohesive unit of the game UI or world.

### 2. Reusable Components
Extract common patterns into reusable scenes:
- `button.tscn` for standard buttons
- `card_slot.tscn` for card display areas

### 3. Scene Inheritance
Use inherited scenes for UI variations:
```
button.tscn (base)
├── primary_button.tscn
├── secondary_button.tscn
└── danger_button.tscn
```

### 4. Signal-Based Communication
- Use signals for parent-child communication
- Use autoload for global game state
- Avoid tight coupling between scenes

## Script Attachment

| Scene Type | Script Pattern | Example |
|------------|---------------|---------|
| Screens | `[SceneName]Screen.gd` | `MainMenuScreen.gd` |
| UI Components | `[ComponentName]UI.gd` | `CardDisplayUI.gd` |
| Game Objects | `[ObjectName].gd` | `PlayingCard.gd` |
| Managers | `[Manager]Manager.gd` | `BattleManager.gd` |

## Scene Instantiation

```gdscript
var scene = preload("res://src/scenes/battle/battle_field.tscn")
var instance = scene.instantiate()
add_child(instance)
```

## Best Practices

1. **Keep scenes small**: Split large scenes into smaller components
2. **Use containers**: Use VBoxContainer, HBoxContainer, GridContainer for layout
3. **Anchor edges properly**: Use anchors_preset for responsive UI
4. **Name meaningful nodes**: Avoid generic names like "Node", "Node2D"
5. **Export important nodes**: Use `@export` for nodes accessed by script
6. **Group related nodes**: Use Node2D/Node containers for organization
