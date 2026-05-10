class_name AchievementSystem
extends Node

signal achievement_unlocked(achievement_id: String)
signal progress_updated(achievement_id: String, progress: float)
signal all_achievements_unlocked

enum AchievementCategory {
	GENERAL,
	HANDS,
	CARDS,
	COLLECTION,
	CHALLENGE
}

var _achievements: Dictionary = {}
var _progress: Dictionary = {}
var _unlocked_ids: Array[String] = []

func _init() -> void:
	_initialize_achievements()

func _initialize_achievements() -> void:
	var achievement_definitions: Array[Dictionary] = [
		{"id": "first_win", "name": "First Victory", "description": "Win your first game", "category": AchievementCategory.GENERAL, "requirement": 1},
		{"id": "win_10", "name": "Seasoned Player", "description": "Win 10 games", "category": AchievementCategory.GENERAL, "requirement": 10},
		{"id": "win_100", "name": "Master", "description": "Win 100 games", "category": AchievementCategory.GENERAL, "requirement": 100},
		{"id": "score_1000", "name": "High Scorer", "description": "Score 1000 points in a single game", "category": AchievementCategory.GENERAL, "requirement": 1000},
		{"id": "score_5000", "name": "Score Master", "description": "Score 5000 points in a single game", "category": AchievementCategory.GENERAL, "requirement": 5000},
		{"id": "play_royal_flush", "name": "Royal Flush!", "description": "Play a Royal Flush", "category": AchievementCategory.HANDS, "requirement": 1},
		{"id": "play_straight_flush", "name": "Straight Flush!", "description": "Play a Straight Flush", "category": AchievementCategory.HANDS, "requirement": 1},
		{"id": "play_four_kind", "name": "Four of a Kind!", "description": "Play Four of a Kind", "category": AchievementCategory.HANDS, "requirement": 1},
		{"id": "play_full_house", "name": "Full House!", "description": "Play a Full House", "category": AchievementCategory.HANDS, "requirement": 1},
		{"id": "play_flush", "name": "Flush!", "description": "Play a Flush", "category": AchievementCategory.HANDS, "requirement": 1},
		{"id": "play_straight", "name": "Straight!", "description": "Play a Straight", "category": AchievementCategory.HANDS, "requirement": 1},
		{"id": "play_three_kind", "name": "Three of a Kind!", "description": "Play Three of a Kind", "category": AchievementCategory.HANDS, "requirement": 1},
		{"id": "play_100_hands", "name": "Card Shark", "description": "Play 100 hands total", "category": AchievementCategory.HANDS, "requirement": 100},
		{"id": "play_1000_hands", "name": "Card Legend", "description": "Play 1000 hands total", "category": AchievementCategory.HANDS, "requirement": 1000},
		{"id": "ace_royal", "name": "Ace in the Hole", "description": "Win with Ace-high Royal Flush", "category": AchievementCategory.CARDS, "requirement": 1},
		{"id": "all_suits_flush", "name": "Four Suits", "description": "Play a Flush with each suit", "category": AchievementCategory.CARDS, "requirement": 4},
		{"id": "collect_jokers_5", "name": "Joker Collector", "description": "Collect 5 different Jokers", "category": AchievementCategory.COLLECTION, "requirement": 5},
		{"id": "collect_jokers_10", "name": "Joker Enthusiast", "description": "Collect 10 different Jokers", "category": AchievementCategory.COLLECTION, "requirement": 10},
		{"id": "ante_8", "name": "Endurance", "description": "Reach Ante 8", "category": AchievementCategory.CHALLENGE, "requirement": 8},
		{"id": "no_damage_run", "name": "Perfect Run", "description": "Win a round without taking damage", "category": AchievementCategory.CHALLENGE, "requirement": 1}
	]
	
	for def in achievement_definitions:
		var achievement = AchievementData.new()
		achievement.id = def["id"]
		achievement.name = def["name"]
		achievement.description = def["description"]
		achievement.category = def["category"]
		achievement.requirement = def["requirement"]
		achievement.current = 0
		achievement.is_unlocked = false
		_achievements[achievement.id] = achievement

func update_progress(achievement_id: String, amount: int = 1) -> void:
	if not _achievements.has(achievement_id):
		return
	
	var achievement = _achievements[achievement_id]
	if achievement.is_unlocked:
		return
	
	achievement.current += amount
	
	var progress = min(float(achievement.current) / float(achievement.requirement), 1.0)
	progress_updated.emit(achievement_id, progress)
	
	if achievement.current >= achievement.requirement:
		unlock_achievement(achievement_id)

func set_progress(achievement_id: String, value: int) -> void:
	if not _achievements.has(achievement_id):
		return
	
	var achievement = _achievements[achievement_id]
	if achievement.is_unlocked:
		return
	
	achievement.current = value
	
	var progress = min(float(achievement.current) / float(achievement.requirement), 1.0)
	progress_updated.emit(achievement_id, progress)
	
	if achievement.current >= achievement.requirement:
		unlock_achievement(achievement_id)

func unlock_achievement(achievement_id: String) -> bool:
	if not _achievements.has(achievement_id):
		return false
	
	var achievement = _achievements[achievement_id]
	if achievement.is_unlocked:
		return false
	
	achievement.is_unlocked = true
	_unlocked_ids.append(achievement_id)
	achievement_unlocked.emit(achievement_id)
	
	if get_unlocked_count() >= get_total_count():
		all_achievements_unlocked.emit()
	
	return true

func is_unlocked(achievement_id: String) -> bool:
	if _achievements.has(achievement_id):
		return _achievements[achievement_id].is_unlocked
	return false

func get_achievement(achievement_id: String) -> AchievementData:
	if _achievements.has(achievement_id):
		return _achievements[achievement_id]
	return null

func get_all_achievements() -> Array[AchievementData]:
	var result: Array[AchievementData] = []
	for achievement in _achievements.values():
		result.append(achievement)
	return result

func get_achievements_by_category(category: AchievementCategory) -> Array[AchievementData]:
	var result: Array[AchievementData] = []
	for achievement in _achievements.values():
		if achievement.category == category:
			result.append(achievement)
	return result

func get_unlocked_count() -> int:
	return _unlocked_ids.size()

func get_total_count() -> int:
	return _achievements.size()

func get_completion_percentage() -> float:
	if get_total_count() == 0:
		return 100.0
	return (float(get_unlocked_count()) / float(get_total_count())) * 100.0

func to_dict() -> Dictionary:
	var achievement_data: Dictionary = {}
	for id in _achievements:
		achievement_data[id] = {
			"current": _achievements[id].current,
			"is_unlocked": _achievements[id].is_unlocked
		}
	return achievement_data

func from_dict(data: Dictionary) -> void:
	for id in data:
		if _achievements.has(id):
			_achievements[id].current = data[id].get("current", 0)
			_achievements[id].is_unlocked = data[id].get("is_unlocked", false)
			if _achievements[id].is_unlocked and not _unlocked_ids.has(id):
				_unlocked_ids.append(id)

func reset_progress() -> void:
	for achievement in _achievements.values():
		achievement.current = 0
		achievement.is_unlocked = false
	_unlocked_ids.clear()


class AchievementData:
	var id: String = ""
	var name: String = ""
	var description: String = ""
	var category: AchievementCategory = AchievementCategory.GENERAL
	var requirement: int = 1
	var current: int = 0
	var is_unlocked: bool = false
	
	func get_progress() -> float:
		if requirement == 0:
			return 1.0
		return min(float(current) / float(requirement), 1.0)
