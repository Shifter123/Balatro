class_name SaveSystem
extends Node

signal save_completed(success: bool)
signal load_completed(success: bool)
signal save_failed(error: String)

const SAVE_FILE_PATH = "user://save_game.json"
const BACKUP_FILE_PATH = "user://save_game_backup.json"
const MAX_BACKUPS = 3

var _current_save_data: Dictionary = {}

func _init() -> void:
	pass

func save_game(game_data: Dictionary) -> bool:
	var save_data = _create_save_data(game_data)
	
	var json_string = JSON.stringify(save_data, "\t")
	if json_string.is_empty():
		push_error("Failed to serialize save data")
		save_failed.emit("Serialization failed")
		return false
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file: %s" % FileAccess.get_open_error())
		save_failed.emit("Could not open save file")
		return false
	
	file.store_string(json_string)
	file.close()
	
	_create_backup()
	
	_current_save_data = save_data
	save_completed.emit(true)
	return true

func _create_save_data(game_data: Dictionary) -> Dictionary:
	return {
		"version": "1.0.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"game": game_data.get("game", {}),
		"progress": game_data.get("progress", {}),
		"stats": game_data.get("stats", {}),
		"unlocks": game_data.get("unlocks", {}),
		"settings": game_data.get("settings", {})
	}

func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		save_failed.emit("Save file does not exist")
		return {}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file: %s" % FileAccess.get_open_error())
		save_failed.emit("Could not open save file")
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse save file JSON")
		save_failed.emit("Invalid save file format")
		return _try_load_backup()
	
	var save_data = json.data as Dictionary
	if not _validate_save_data(save_data):
		push_error("Invalid save data structure")
		save_failed.emit("Corrupted save file")
		return _try_load_backup()
	
	_current_save_data = save_data
	load_completed.emit(true)
	return save_data

func _validate_save_data(data: Dictionary) -> bool:
	if not data.has("version"):
		return false
	if not data.has("game"):
		return false
	return true

func _create_backup() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var backup_name = BACKUP_FILE_PATH
		var dir = DirAccess.open("user://")
		if dir:
			var backup_file = FileAccess.open(backup_name, FileAccess.WRITE)
			if backup_file:
				var original_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
				if original_file:
					backup_file.store_string(original_file.get_as_text())
					original_file.close()
				backup_file.close()

func _try_load_backup() -> Dictionary:
	if not FileAccess.file_exists(BACKUP_FILE_PATH):
		return {}
	
	var file = FileAccess.open(BACKUP_FILE_PATH, FileAccess.READ)
	if file == null:
		return {}
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return {}
	
	_current_save_data = json.data as Dictionary
	load_completed.emit(true)
	return _current_save_data

func delete_save() -> bool:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		DirAccess.remove_absolute(SAVE_FILE_PATH)
	
	if FileAccess.file_exists(BACKUP_FILE_PATH):
		DirAccess.remove_absolute(BACKUP_FILE_PATH)
	
	_current_save_data.clear()
	return true

func save_exists() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func get_save_info() -> Dictionary:
	if not save_exists():
		return {}
	
	var data = load_game()
	if data.is_empty():
		return {}
	
	return {
		"version": data.get("version", "unknown"),
		"timestamp": data.get("timestamp", "unknown"),
		"has_game": data.has("game"),
		"has_progress": data.has("progress"),
		"has_stats": data.has("stats")
	}

func create_new_save() -> Dictionary:
	_current_save_data = {
		"version": "1.0.0",
		"timestamp": Time.get_datetime_string_from_system(),
		"game": {},
		"progress": {
			"highest_ante": 0,
			"highest_score": 0,
			"total_games": 0,
			"wins": 0
		},
		"stats": {
			"total_hands_played": 0,
			"total_cards_played": 0,
			"highest_hand_type": 0,
			"royal_flushes": 0,
			"straight_flushes": 0,
			"four_of_kinds": 0
		},
		"unlocks": {},
		"settings": {
			"master_volume": 1.0,
			"music_volume": 0.8,
			"sfx_volume": 1.0
		}
	}
	
	return _current_save_data

func get_current_save() -> Dictionary:
	return _current_save_data
