extends Control

signal play_pressed
signal continue_pressed
signal settings_pressed
signal quit_pressed

@onready var play_button: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var continue_button: Button = $CenterContainer/VBoxContainer/ContinueButton
@onready var settings_button: Button = $CenterContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $CenterContainer/VBoxContainer/QuitButton
@onready var version_label: Label = $VersionLabel

var save_system: SaveSystem
var has_save: bool = false

func _ready() -> void:
	save_system = SaveSystem.new()
	add_child(save_system)
	
	_check_save_exists()
	_update_buttons()
	_update_version()
	
	play_button.pressed.connect(_on_play_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _check_save_exists() -> void:
	has_save = save_system.save_exists()

func _update_buttons() -> void:
	continue_button.disabled = not has_save

func _update_version() -> void:
	if version_label:
		version_label.text = "v%s" % Globals.game_version

func _on_play_pressed() -> void:
	play_pressed.emit()
	_get_tree().change_scene_to_file("res://src/scenes/game.tscn")

func _on_continue_pressed() -> void:
	if not has_save:
		return
	continue_pressed.emit()
	_try_load_and_start()

func _on_settings_pressed() -> void:
	settings_pressed.emit()
	_show_settings()

func _on_quit_pressed() -> void:
	quit_pressed.emit()
	_get_tree().quit()

func _try_load_and_start() -> void:
	var save_data = save_system.load_game()
	if save_data.is_empty():
		_show_error("Failed to load save")
		return
	_get_tree().change_scene_to_file("res://src/scenes/game.tscn")

func _show_settings() -> void:
	pass

func _show_error(message: String) -> void:
	push_error(message)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_ESCAPE:
				_get_tree().quit()
