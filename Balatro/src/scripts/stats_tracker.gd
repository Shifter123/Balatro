class_name StatsTracker
extends Node

signal stat_changed(stat_id: String, new_value: int)
signal milestone_reached(milestone_id: String)

var _stats: Dictionary = {}

func _init() -> void:
	_initialize_stats()

func _initialize_stats() -> void:
	_stats = {
		"games_played": 0,
		"games_won": 0,
		"games_lost": 0,
		"total_score": 0,
		"highest_score": 0,
		"highest_ante_reached": 0,
		"total_hands_played": 0,
		"total_cards_played": 0,
		"royal_flushes": 0,
		"straight_flushes": 0,
		"four_of_kinds": 0,
		"full_houses": 0,
		"flushes": 0,
		"straights": 0,
		"three_of_kinds": 0,
		"two_pairs": 0,
		"one_pairs": 0,
		"high_cards": 0,
		"total_discards": 0,
		"total_draws": 0,
		"chips_earned": 0,
		"chips_spent": 0,
		"jokers_collected": 0,
		"items_collected": 0,
		"time_played_seconds": 0
	}

func increment(stat_id: String, amount: int = 1) -> void:
	if not _stats.has(stat_id):
		push_warning("Unknown stat: %s" % stat_id)
		return
	
	var old_value = _stats[stat_id]
	_stats[stat_id] = old_value + amount
	stat_changed.emit(stat_id, _stats[stat_id])
	_check_milestones(stat_id)

func set_stat(stat_id: String, value: int) -> void:
	if not _stats.has(stat_id):
		push_warning("Unknown stat: %s" % stat_id)
		return
	
	_stats[stat_id] = value
	stat_changed.emit(stat_id, value)
	_check_milestones(stat_id)

func get_stat(stat_id: String) -> int:
	if _stats.has(stat_id):
		return _stats[stat_id]
	return 0

func add_game_played() -> void:
	increment("games_played")
	increment("time_played_seconds", 0)

func add_game_won(final_score: int, ante_reached: int) -> void:
	increment("games_won")
	if final_score > _stats["highest_score"]:
		set_stat("highest_score", final_score)
	if ante_reached > _stats["highest_ante_reached"]:
		set_stat("highest_ante_reached", ante_reached)

func add_game_lost() -> void:
	increment("games_lost")

func add_hand_played() -> void:
	increment("total_hands_played")

func add_cards_played(count: int) -> void:
	increment("total_cards_played", count)

func record_hand_type(hand_type: int) -> void:
	var stat_id = _get_hand_type_stat_id(hand_type)
	if stat_id != "":
		increment(stat_id)

func _get_hand_type_stat_id(hand_type: int) -> String:
	match hand_type:
		HandEvaluator.HandType.ROYAL_FLUSH: return "royal_flushes"
		HandEvaluator.HandType.STRAIGHT_FLUSH: return "straight_flushes"
		HandEvaluator.HandType.FOUR_OF_A_KIND: return "four_of_kinds"
		HandEvaluator.HandType.FULL_HOUSE: return "full_houses"
		HandEvaluator.HandType.FLUSH: return "flushes"
		HandEvaluator.HandType.STRAIGHT: return "straights"
		HandEvaluator.HandType.THREE_OF_A_KIND: return "three_of_kinds"
		HandEvaluator.HandType.TWO_PAIR: return "two_pairs"
		HandEvaluator.HandType.ONE_PAIR: return "one_pairs"
		HandEvaluator.HandType.HIGH_CARD: return "high_cards"
	return ""

func add_discard() -> void:
	increment("total_discards")

func add_draw() -> void:
	increment("total_draws")

func add_chips_earned(amount: int) -> void:
	increment("chips_earned", amount)

func add_chips_spent(amount: int) -> void:
	increment("chips_spent", amount)

func add_joker_collected() -> void:
	increment("jokers_collected")

func add_item_collected() -> void:
	increment("items_collected")

func add_time_played(seconds: int) -> void:
	increment("time_played_seconds", seconds)

func get_win_rate() -> float:
	if _stats["games_played"] == 0:
		return 0.0
	return float(_stats["games_won"]) / float(_stats["games_played"])

func get_average_score() -> float:
	if _stats["games_played"] == 0:
		return 0.0
	return float(_stats["total_score"]) / float(_stats["games_played"])

func get_total_hand_types() -> int:
	return _stats["royal_flushes"] + _stats["straight_flushes"] + _stats["four_of_kinds"] +
		   _stats["full_houses"] + _stats["flushes"] + _stats["straights"] +
		   _stats["three_of_kinds"] + _stats["two_pairs"] + _stats["one_pairs"] +
		   _stats["high_cards"]

func get_stats() -> Dictionary:
	return _stats.duplicate()

func to_dict() -> Dictionary:
	return {
		"stats": _stats.duplicate(),
		"milestones": _get_milestone_data()
	}

func _get_milestone_data() -> Dictionary:
	return {
		"milestone_scores": [1000, 5000, 10000],
		"milestone_hands": [100, 500, 1000]
	}

func _check_milestones(stat_id: String) -> void:
	match stat_id:
		"highest_score":
			if _stats[stat_id] >= 1000:
				milestone_reached.emit("score_1000")
			if _stats[stat_id] >= 5000:
				milestone_reached.emit("score_5000")
		"total_hands_played":
			if _stats[stat_id] >= 100:
				milestone_reached.emit("hands_100")
			if _stats[stat_id] >= 1000:
				milestone_reached.emit("hands_1000")

func from_dict(data: Dictionary) -> void:
	if data.has("stats"):
		for stat_id in data["stats"]:
			if _stats.has(stat_id):
				_stats[stat_id] = data["stats"][stat_id]

func reset_stats() -> void:
	_initialize_stats()
