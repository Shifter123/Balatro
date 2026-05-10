class_name RandomSystem
extends Node

signal seed_changed(seed_value: int)
signal random_generated(value: float, type: String)

var _rng: RandomNumberGenerator
var _initial_seed: int = 0
var _call_count: int = 0

var _weighted_pools: Dictionary = {}
var _compensation_values: Dictionary = {}

func _init() -> void:
	_rng = RandomNumberGenerator.new()
	randomize_seed()

func randomize_seed() -> void:
	_initial_seed = Time.get_ticks_usec()
	_rng.seed = _initial_seed
	_call_count = 0
	seed_changed.emit(_initial_seed)

func set_seed(seed_value: int) -> void:
	_initial_seed = seed_value
	_rng.seed = seed_value
	_call_count = 0
	seed_changed.emit(_initial_seed)

func get_seed() -> int:
	return _initial_seed

func randf() -> float:
	_call_count += 1
	var value = _rng.randf()
	random_generated.emit(value, "float")
	return value

func randf_range(from_value: float, to_value: float) -> float:
	_call_count += 1
	var value = _rng.randf_range(from_value, to_value)
	random_generated.emit(value, "range")
	return value

func randi() -> int:
	_call_count += 1
	var value = _rng.randi()
	random_generated.emit(value, "int")
	return value

func randi_range(from_value: int, to_value: int) -> int:
	_call_count += 1
	var value = _rng.randi_range(from_value, to_value)
	random_generated.emit(value, "int_range")
	return value

func choose(array: Array) -> Variant:
	if array.is_empty():
		return null
	return array[randi() % array.size()]

func choose_weighted(weights: Array[float]) -> int:
	if weights.is_empty():
		return -1
	
	var total_weight = 0.0
	for w in weights:
		total_weight += w
	
	if total_weight <= 0:
		return randi() % weights.size()
	
	var random_value = randf() * total_weight
	var cumulative = 0.0
	
	for i in range(weights.size()):
		cumulative += weights[i]
		if random_value < cumulative:
			return i
	
	return weights.size() - 1

func create_weighted_pool(pool_id: String, items: Array[Dictionary]) -> void:
	_weighted_pools[pool_id] = items.duplicate()

func get_from_weighted_pool(pool_id: String) -> Dictionary:
	if not _weighted_pools.has(pool_id):
		return {}
	
	var pool = _weighted_pools[pool_id]
	if pool.is_empty():
		return {}
	
	var weights: Array[float] = []
	for item in pool:
		weights.append(item.get("weight", 1.0))
	
	var index = choose_weighted(weights)
	var result = pool[index]
	
	pool.erase(result)
	_weighted_pools[pool_id] = pool
	
	return result

func reset_weighted_pool(pool_id: String, items: Array[Dictionary]) -> void:
	_weighted_pools[pool_id] = items.duplicate()

func compensate_random(target_probability: float, event_id: String = "") -> bool:
	if not _compensation_values.has(event_id):
		_compensation_values[event_id] = {
			"accumulator": 0.0,
			"attempts": 0
		}
	
	var state = _compensation_values[event_id]
	state["attempts"] += 1
	
	var effective_prob = target_probability + state["accumulator"]
	
	if randf() < effective_prob:
		state["accumulator"] = 0.0
		return true
	else:
		state["accumulator"] += target_probability
		return false

func reset_compensation(event_id: String = "") -> void:
	if event_id.is_empty():
		_compensation_values.clear()
	elif _compensation_values.has(event_id):
		_compensation_values.erase(event_id)

func shuffle_array(array: Array) -> Array:
	var shuffled = array.duplicate()
	var result: Array = []
	
	while not shuffled.is_empty():
		var index = randi() % shuffled.size()
		result.append(shuffled[index])
		shuffled.remove_at(index)
	
	return result

func get_call_count() -> int:
	return _call_count

func reset_call_count() -> void:
	_call_count = 0
