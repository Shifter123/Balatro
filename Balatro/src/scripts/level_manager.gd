class_name LevelManager
extends Node

signal level_started(level: LevelData)
signal level_completed(level: LevelData, success: bool)
signal ante_completed(ante_level: int)
signal stage_completed(stage: int)
signal all_antes_completed

var current_ante: int = 1
var current_stage: int = 1
var max_ante: int = 8
var max_stage: int = 4

var levels_per_ante: int = 2
var stages_per_ante: int = 2

var available_jokers: int = 2
var shop_slots: int = 3

var _level_templates: Array[Dictionary] = []
var _blind_templates: Dictionary = {}
var _current_blind_index: int = 0

func _init() -> void:
	_load_level_templates()

func _ready() -> void:
	pass

func _load_level_templates() -> void:
	var file_path = "res://data/levels/levels.json"
	if not FileAccess.file_exists(file_path):
		push_warning("Level templates file not found")
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return
	
	var data = json.data as Dictionary
	
	if data.has("levels"):
		_level_templates = data["levels"]
	
	if data.has("blinds"):
		for blind_data in data["blinds"]:
			var id = blind_data.get("id", "")
			_blind_templates[id] = blind_data

func start_new_run() -> void:
	current_ante = 1
	current_stage = 1
	_current_blind_index = 0
	_update_difficulty()

func get_current_level() -> LevelData:
	var level = LevelData.new()
	level.ante = current_ante
	level.stage = current_stage
	level.level_number = (current_ante - 1) * stages_per_ante + current_stage
	
	var level_id = "level_%d_%d" % [current_ante, current_stage]
	level.id = level_id
	
	var template = _find_level_template(level_id)
	if template:
		level.name = template.get("name", level_id)
		level.available_jokers = template.get("available_jokers", available_jokers)
		level.shop_slots = template.get("shop_slots", shop_slots)
		level.is_boss = template.get("is_boss", false)
	
	return level

func _find_level_template(level_id: String) -> Dictionary:
	for template in _level_templates:
		if template.get("id", "") == level_id:
			return template
	return {}

func get_available_blinds() -> Array[Blind]:
	var level = get_current_level()
	var blinds: Array[Blind] = []
	
	var blind_ids = level.get_blind_ids()
	for blind_id in blind_ids:
		var blind = create_blind(blind_id)
		if blind:
			blinds.append(blind)
	
	return blinds

func get_next_blind() -> Blind:
	var level = get_current_level()
	var blind_ids = level.get_blind_ids()
	
	if _current_blind_index < blind_ids.size():
		var blind_id = blind_ids[_current_blind_index]
		_current_blind_index += 1
		return create_blind(blind_id)
	
	return null

func create_blind(blind_id: String) -> Blind:
	if not _blind_templates.has(blind_id):
		return null
	
	var template = _blind_templates[blind_id]
	var blind = Blind.new()
	
	blind.id = blind_id
	blind.name = template.get("name", blind_id)
	blind.base_score = template.get("base_score", 200)
	blind.reward_amount = template.get("reward", 3)
	
	var type_str = template.get("type", "small")
	match type_str:
		"small": blind.blind_type = Blind.BlindType.SMALL
		"big": blind.blind_type = Blind.BlindType.BIG
		"boss": blind.blind_type = Blind.BlindType.BOSS
	
	return blind

func complete_blind(success: bool) -> void:
	if success:
		level_completed.emit(get_current_level(), true)
	else:
		level_completed.emit(get_current_level(), false)

func advance_level() -> bool:
	current_stage += 1
	
	if current_stage > stages_per_ante:
		current_stage = 1
		current_ante += 1
		ante_completed.emit(current_ante - 1)
	
	if current_ante > max_ante:
		all_antes_completed.emit()
		return false
	
	_current_blind_index = 0
	_update_difficulty()
	
	var level = get_current_level()
	level_started.emit(level)
	return true

func _update_difficulty() -> void:
	var ante_multiplier = 1.0 + (current_ante - 1) * 0.5
	available_jokers = 2 + int((current_ante - 1) / 2)
	shop_slots = 3 + int((current_ante - 1) / 2)

func get_ante_multiplier() -> float:
	return 1.0 + (current_ante - 1) * 0.5

func is_final_ante() -> bool:
	return current_ante >= max_ante

func get_progress() -> Dictionary:
	return {
		"current_ante": current_ante,
		"current_stage": current_stage,
		"max_ante": max_ante,
		"max_stage": max_stage,
		"progress_percent": float((current_ante - 1) * stages_per_ante + current_stage) / float(max_ante * stages_per_ante) * 100.0
	}

func to_dict() -> Dictionary:
	return {
		"current_ante": current_ante,
		"current_stage": current_stage,
		"max_ante": max_ante,
		"blind_index": _current_blind_index
	}

func from_dict(data: Dictionary) -> void:
	current_ante = data.get("current_ante", 1)
	current_stage = data.get("current_stage", 1)
	max_ante = data.get("max_ante", 8)
	_current_blind_index = data.get("blind_index", 0)


class LevelData:
	var id: String = ""
	var name: String = ""
	var ante: int = 1
	var stage: int = 1
	var level_number: int = 1
	
	var available_jokers: int = 2
	var shop_slots: int = 3
	var voucher_chance: float = 0.2
	
	var is_boss: bool = false
	
	var _blind_ids: Array[String] = ["small_blind", "big_blind"]
	
	func get_blind_ids() -> Array[String]:
		return _blind_ids
	
	func set_blind_ids(ids: Array[String]) -> void:
		_blind_ids = ids
