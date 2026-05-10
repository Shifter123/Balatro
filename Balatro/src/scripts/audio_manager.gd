extends Node

signal volume_changed(bus_name: String, volume: float)
signal muted_changed(bus_name: String, muted: bool)

enum SoundType {
	UI_CLICK,
	UI_HOVER,
	UI_BACK,
	BUTTON_CLICK,
	CARD_DRAW,
	CARD_PLAY,
	CARD_DISCARD,
	CARD_SELECT,
	CARD_DESELECT,
	HAND_WIN,
	HAND_LOSE,
	SHOP_OPEN,
	SHOP_CLOSE,
	JOKER_EQUIP,
	JOKER_TRIGGER,
	LEVEL_COMPLETE,
	GAME_OVER,
	MENU_SELECT,
	COIN_GAIN,
	COIN_SPEND
}

var _audio_players: Dictionary = {}
var _sounds: Dictionary = {}
var _volumes: Dictionary = {
	"Master": 1.0,
	"Music": 0.8,
	"SFX": 1.0
}
var _muted: Dictionary = {
	"Master": false,
	"Music": false,
	"SFX": false
}

func _ready() -> void:
	_initialize_audio_buses()
	_initialize_sounds()

func _initialize_audio_buses() -> void:
	for bus_name in ["Master", "Music", "SFX"]:
		var bus_index = AudioServer.get_bus_index(bus_name)
		if bus_index == -1:
			bus_index = AudioServer.add_bus()
			AudioServer.set_bus_name(bus_index, bus_name)

func _initialize_sounds() -> void:
	_sounds = {
		SoundType.UI_CLICK: {"file": "res://assets/audio/ui_click.wav", "bus": "SFX"},
		SoundType.UI_HOVER: {"file": "res://assets/audio/ui_hover.wav", "bus": "SFX"},
		SoundType.UI_BACK: {"file": "res://assets/audio/ui_back.wav", "bus": "SFX"},
		SoundType.BUTTON_CLICK: {"file": "res://assets/audio/button_click.wav", "bus": "SFX"},
		SoundType.CARD_DRAW: {"file": "res://assets/audio/card_draw.wav", "bus": "SFX"},
		SoundType.CARD_PLAY: {"file": "res://assets/audio/card_play.wav", "bus": "SFX"},
		SoundType.CARD_DISCARD: {"file": "res://assets/audio/card_discard.wav", "bus": "SFX"},
		SoundType.CARD_SELECT: {"file": "res://assets/audio/card_select.wav", "bus": "SFX"},
		SoundType.CARD_DESELECT: {"file": "res://assets/audio/card_deselect.wav", "bus": "SFX"},
		SoundType.HAND_WIN: {"file": "res://assets/audio/hand_win.wav", "bus": "SFX"},
		SoundType.HAND_LOSE: {"file": "res://assets/audio/hand_lose.wav", "bus": "SFX"},
		SoundType.SHOP_OPEN: {"file": "res://assets/audio/shop_open.wav", "bus": "SFX"},
		SoundType.SHOP_CLOSE: {"file": "res://assets/audio/shop_close.wav", "bus": "SFX"},
		SoundType.JOKER_EQUIP: {"file": "res://assets/audio/joker_equip.wav", "bus": "SFX"},
		SoundType.JOKER_TRIGGER: {"file": "res://assets/audio/joker_trigger.wav", "bus": "SFX"},
		SoundType.LEVEL_COMPLETE: {"file": "res://assets/audio/level_complete.wav", "bus": "SFX"},
		SoundType.GAME_OVER: {"file": "res://assets/audio/game_over.wav", "bus": "SFX"},
		SoundType.MENU_SELECT: {"file": "res://assets/audio/menu_select.wav", "bus": "SFX"},
		SoundType.COIN_GAIN: {"file": "res://assets/audio/coin_gain.wav", "bus": "SFX"},
		SoundType.COIN_SPEND: {"file": "res://assets/audio/coin_spend.wav", "bus": "SFX"}
	}

func play_sound(sound_type: SoundType, volume_db: float = 0.0) -> void:
	if not _sounds.has(sound_type):
		return
	
	var sound_data = _sounds[sound_type]
	var bus = sound_data["bus"]
	
	if _muted.get(bus, false) or _muted.get("Master", false):
		return
	
	var player = _get_or_create_player(bus)
	
	var audio_file = sound_data["file"]
	if not FileAccess.file_exists(audio_file):
		return
	
	var stream = load(audio_file)
	if stream == null:
		return
	
	player.stream = stream
	player.volume_db = volume_db + linear_to_db(_volumes.get(bus, 1.0))
	player.play()

func play_ui_click() -> void:
	play_sound(SoundType.UI_CLICK)

func play_card_draw() -> void:
	play_sound(SoundType.CARD_DRAW)

func play_card_play() -> void:
	play_sound(SoundType.CARD_PLAY)

func play_hand_result(success: bool) -> void:
	if success:
		play_sound(SoundType.HAND_WIN)
	else:
		play_sound(SoundType.HAND_LOSE)

func play_coin_sound(gain: bool) -> void:
	if gain:
		play_sound(SoundType.COIN_GAIN)
	else:
		play_sound(SoundType.COIN_SPEND)

func _get_or_create_player(bus: String) -> AudioStreamPlayer:
	if not _audio_players.has(bus):
		var player = AudioStreamPlayer.new()
		player.bus = bus
		add_child(player)
		_audio_players[bus] = player
	return _audio_players[bus]

func set_volume(bus_name: String, volume: float) -> void:
	_volumes[bus_name] = clamp(volume, 0.0, 1.0)
	_apply_volume(bus_name)
	volume_changed.emit(bus_name, _volumes[bus_name])

func get_volume(bus_name: String) -> float:
	return _volumes.get(bus_name, 1.0)

func set_muted(bus_name: String, muted: bool) -> void:
	_muted[bus_name] = muted
	_apply_volume(bus_name)
	muted_changed.emit(bus_name, muted)

func is_muted(bus_name: String) -> bool:
	return _muted.get(bus_name, false)

func _apply_volume(bus_name: String) -> void:
	var volume = _volumes.get(bus_name, 1.0)
	if _muted.get(bus_name, false):
		volume = 0.0
	
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

func stop_all() -> void:
	for player in _audio_players.values():
		player.stop()

func save_settings() -> Dictionary:
	return {
		"volumes": _volumes.duplicate(),
		"muted": _muted.duplicate()
	}

func load_settings(settings: Dictionary) -> void:
	if settings.has("volumes"):
		for bus in settings["volumes"]:
			set_volume(bus, settings["volumes"][bus])
	
	if settings.has("muted"):
		for bus in settings["muted"]:
			set_muted(bus, settings["muted"][bus])
