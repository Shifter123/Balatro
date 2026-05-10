class_name UnlockSystem
extends Node

signal unlock_changed(unlock_type: String, id: String, is_unlocked: bool)
signal all_unlocks_loaded

enum UnlockType {
	CARD,
	JOKER,
	STICKER,
	BLIND,
	VOUCHER,
	SPECIAL
}

var _unlocks: Dictionary = {
	UnlockType.CARD: {},
	UnlockType.JOKER: {},
	UnlockType.STICKER: {},
	UnlockType.BLIND: {},
	UnlockType.VOUCHER: {},
	UnlockType.SPECIAL: {}
}

var _default_unlocks: Dictionary = {}

func _init() -> void:
	_initialize_defaults()

func _initialize_defaults() -> void:
	_default_unlocks[UnlockType.CARD] = []
	_default_unlocks[UnlockType.JOKER] = []
	_default_unlocks[UnlockType.STICKER] = []
	_default_unlocks[UnlockType.BLIND] = ["small_blind", "big_blind"]
	_default_unlocks[UnlockType.VOUCHER] = []
	_default_unlocks[UnlockType.SPECIAL] = []

func unlock(unlock_type: UnlockType, id: String) -> bool:
	if is_unlocked(unlock_type, id):
		return false
	
	_unlocks[unlock_type][id] = true
	unlock_changed.emit(_get_unlock_type_name(unlock_type), id, true)
	return true

func lock(unlock_type: UnlockType, id: String) -> bool:
	if not is_unlocked(unlock_type, id):
		return false
	
	_unlocks[unlock_type][id] = false
	unlock_changed.emit(_get_unlock_type_name(unlock_type), id, false)
	return true

func is_unlocked(unlock_type: UnlockType, id: String) -> bool:
	if _unlocks[unlock_type].has(id):
		return _unlocks[unlock_type][id]
	
	if _default_unlocks[unlock_type].has(id):
		return true
	
	return false

func get_unlocked_ids(unlock_type: UnlockType) -> Array[String]:
	var result: Array[String] = []
	
	for id in _unlocks[unlock_type]:
		if _unlocks[unlock_type][id]:
			result.append(id)
	
	for id in _default_unlocks[unlock_type]:
		if not result.has(id):
			result.append(id)
	
	return result

func get_locked_ids(unlock_type: UnlockType) -> Array[String]:
	var all_ids = _get_all_ids_for_type(unlock_type)
	var unlocked = get_unlocked_ids(unlock_type)
	var locked: Array[String] = []
	
	for id in all_ids:
		if not unlocked.has(id):
			locked.append(id)
	
	return locked

func _get_all_ids_for_type(unlock_type: UnlockType) -> Array[String]:
	var result: Array[String] = []
	match unlock_type:
		UnlockType.CARD:
			for suit in Globals.Suit.values():
				for rank in Globals.CardRank.values():
					result.append("%s_%d" % [Globals.SUIT_NAMES[suit].to_lower(), rank])
		UnlockType.JOKER:
			result = _get_joker_ids()
		UnlockType.STICKER:
			result = ["lucky", "glass", "steel", "golden", "negative"]
		UnlockType.BLIND:
			result = ["small_blind", "big_blind", "boss_blind"]
		UnlockType.VOUCHER:
			result = ["voucher_1", "voucher_2", "voucher_3"]
		UnlockType.SPECIAL:
			result = ["unlock_1", "unlock_2"]
	return result

func _get_joker_ids() -> Array[String]:
	var ids: Array[String] = []
	for i in range(1, 21):
		ids.append("joker_%d" % i)
	return ids

func _get_unlock_type_name(unlock_type: UnlockType) -> String:
	match unlock_type:
		UnlockType.CARD: return "card"
		UnlockType.JOKER: return "joker"
		UnlockType.STICKER: return "sticker"
		UnlockType.BLIND: return "blind"
		UnlockType.VOUCHER: return "voucher"
		UnlockType.SPECIAL: return "special"
	return "unknown"

func unlock_all() -> void:
	for unlock_type in UnlockType.values():
		var ids = _get_all_ids_for_type(unlock_type)
		for id in ids:
			_unlocks[unlock_type][id] = true

func reset_all() -> void:
	for unlock_type in UnlockType.values():
		_unlocks[unlock_type].clear()
	_initialize_defaults()

func to_dict() -> Dictionary:
	var result: Dictionary = {}
	for unlock_type in UnlockType.values():
		result[_get_unlock_type_name(unlock_type)] = get_unlocked_ids(unlock_type)
	return result

func from_dict(data: Dictionary) -> void:
	_unlocks.clear()
	for unlock_type in UnlockType.values():
		var type_name = _get_unlock_type_name(unlock_type)
		if data.has(type_name):
			var ids: Array = data[type_name]
			for id in ids:
				_unlocks[unlock_type][id] = true
	all_unlocks_loaded.emit()

func get_unlock_count(unlock_type: UnlockType) -> int:
	return get_unlocked_ids(unlock_type).size()

func get_total_count(unlock_type: UnlockType) -> int:
	return _get_all_ids_for_type(unlock_type).size()

func get_unlock_percentage(unlock_type: UnlockType) -> float:
	var total = get_total_count(unlock_type)
	if total == 0:
		return 100.0
	return (float(get_unlock_count(unlock_type)) / float(total)) * 100.0
