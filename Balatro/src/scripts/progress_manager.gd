class_name ProgressManager
extends Node

signal progress_loaded
signal progress_saved
signal achievement_unlocked(achievement_id: String)

var save_system: SaveSystem
var stats_tracker: StatsTracker
var unlock_system: UnlockSystem
var achievement_system: AchievementSystem

func _init() -> void:
	_initialize_systems()

func _initialize_systems() -> void:
	save_system = SaveSystem.new()
	stats_tracker = StatsTracker.new()
	unlock_system = UnlockSystem.new()
	achievement_system = AchievementSystem.new()
	
	add_child(save_system)
	add_child(stats_tracker)
	add_child(unlock_system)
	add_child(achievement_system)
	
	_connect_signals()

func _connect_signals() -> void:
	achievement_system.achievement_unlocked.connect(_on_achievement_unlocked)

func load_progress() -> bool:
	if not save_system.save_exists():
		create_new_progress()
		return true
	
	var data = save_system.load_game()
	if data.is_empty():
		push_error("Failed to load progress")
		return false
	
	if data.has("stats"):
		stats_tracker.from_dict(data["stats"])
	if data.has("unlocks"):
		unlock_system.from_dict(data["unlocks"])
	if data.has("achievements"):
		achievement_system.from_dict(data["achievements"])
	
	progress_loaded.emit()
	return true

func save_progress() -> bool:
	var game_data = {
		"stats": stats_tracker.to_dict(),
		"unlocks": unlock_system.to_dict(),
		"achievements": achievement_system.to_dict()
	}
	
	var result = save_system.save_game(game_data)
	if result:
		progress_saved.emit()
	return result

func create_new_progress() -> void:
	save_system.create_new_save()
	stats_tracker.reset_stats()
	unlock_system.reset_all()
	achievement_system.reset_progress()

func record_game_start() -> void:
	stats_tracker.add_game_played()

func record_hand_played(hand_result: Dictionary) -> void:
	stats_tracker.add_hand_played()
	stats_tracker.add_cards_played(hand_result.get("cards", []).size())
	stats_tracker.record_hand_type(hand_result.get("type", 0))
	
	var hand_type = hand_result.get("type", 0)
	_try_unlock_hand_achievement(hand_type)

func record_game_end(won: bool, final_score: int, ante_reached: int) -> void:
	if won:
		stats_tracker.add_game_won(final_score, ante_reached)
		achievement_system.update_progress("first_win")
		achievement_system.update_progress("win_10")
		achievement_system.update_progress("win_100")
	else:
		stats_tracker.add_game_lost()
	
	if final_score >= 1000:
		achievement_system.update_progress("score_1000", final_score)
	if final_score >= 5000:
		achievement_system.update_progress("score_5000", final_score)

func record_joker_collected(joker_id: String) -> void:
	stats_tracker.add_joker_collected()
	if not unlock_system.is_unlocked(UnlockSystem.UnlockType.JOKER, joker_id):
		unlock_system.unlock(UnlockSystem.UnlockType.JOKER, joker_id)

func record_item_collected(item_id: String) -> void:
	stats_tracker.add_item_collected()

func _try_unlock_hand_achievement(hand_type: int) -> void:
	match hand_type:
		HandEvaluator.HandType.ROYAL_FLUSH:
			achievement_system.unlock_achievement("play_royal_flush")
		HandEvaluator.HandType.STRAIGHT_FLUSH:
			achievement_system.unlock_achievement("play_straight_flush")
		HandEvaluator.HandType.FOUR_OF_A_KIND:
			achievement_system.unlock_achievement("play_four_kind")
		HandEvaluator.HandType.FULL_HOUSE:
			achievement_system.unlock_achievement("play_full_house")
		HandEvaluator.HandType.FLUSH:
			achievement_system.unlock_achievement("play_flush")
		HandEvaluator.HandType.STRAIGHT:
			achievement_system.unlock_achievement("play_straight")
		HandEvaluator.HandType.THREE_OF_A_KIND:
			achievement_system.unlock_achievement("play_three_kind")

func _on_achievement_unlocked(achievement_id: String) -> void:
	achievement_unlocked.emit(achievement_id)

func get_stats_summary() -> Dictionary:
	return {
		"games_played": stats_tracker.get_stat("games_played"),
		"games_won": stats_tracker.get_stat("games_won"),
		"win_rate": stats_tracker.get_win_rate(),
		"highest_score": stats_tracker.get_stat("highest_score"),
		"total_hands": stats_tracker.get_stat("total_hands_played"),
		"achievements_unlocked": achievement_system.get_unlocked_count(),
		"achievements_total": achievement_system.get_total_count()
	}

func get_unlock_summary() -> Dictionary:
	return {
		"jokers": {
			"unlocked": unlock_system.get_unlock_count(UnlockSystem.UnlockType.JOKER),
			"total": unlock_system.get_total_count(UnlockSystem.UnlockType.JOKER)
		},
		"items": {
			"unlocked": unlock_system.get_unlock_count(UnlockSystem.UnlockType.STICKER),
			"total": unlock_system.get_total_count(UnlockSystem.UnlockType.STICKER)
		}
	}
