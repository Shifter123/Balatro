extends Control

signal settings_closed

@onready var master_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MasterVolumeSlider
@onready var music_slider: HSlider = $Panel/MarginContainer/VBoxContainer/MusicVolumeSlider
@onready var sfx_slider: HSlider = $Panel/MarginContainer/VBoxContainer/SFXVolumeSlider
@onready var back_button: Button = $Panel/MarginContainer/VBoxContainer/BackButton

var settings: Dictionary = {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0
}

func _ready() -> void:
	_load_settings()
	_update_sliders()
	
	back_button.pressed.connect(_on_back_pressed)
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

func _load_settings() -> void:
	pass

func _update_sliders() -> void:
	master_slider.value = settings["master_volume"]
	music_slider.value = settings["music_volume"]
	sfx_slider.value = settings["sfx_volume"]

func _on_master_changed(value: float) -> void:
	settings["master_volume"] = value
	_apply_settings()

func _on_music_changed(value: float) -> void:
	settings["music_volume"] = value
	_apply_settings()

func _on_sfx_changed(value: float) -> void:
	settings["sfx_volume"] = value
	_apply_settings()

func _apply_settings() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(settings["master_volume"]))

func _on_back_pressed() -> void:
	_save_settings()
	settings_closed.emit()
	queue_free()

func _save_settings() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_on_back_pressed()
