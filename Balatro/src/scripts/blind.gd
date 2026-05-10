class_name Blind
extends Node

enum BlindType {
	SMALL,
	BIG,
	BOSS
}

signal blind_defeated
signal blind_started
signal blind_scored(final_score: int)

var id: String = ""
var name: String = ""
var description: String = ""

var blind_type: BlindType = BlindType.SMALL

var base_score: int = 200
var score_multiplier: float = 1.0

var reward_type: String = "money"
var reward_amount: int = 3

var tags: Array[String] = []

func setup(p_id: String, p_name: String, p_type: BlindType, p_base_score: int) -> void:
	id = p_id
	name = p_name
	blind_type = p_type
	base_score = p_base_score

func get_score(ante_level: int) -> int:
	var scaled_score = base_score
	var multiplier = 1.0 + (ante_level - 1) * 0.5
	return int(float(scaled_score) * multiplier * score_multiplier)

func get_reward() -> Dictionary:
	return {
		"type": reward_type,
		"amount": reward_amount
	}

func get_display_name() -> String:
	return name

func get_type_name() -> String:
	match blind_type:
		BlindType.SMALL: return "Small Blind"
		BlindType.BIG: return "Big Blind"
		BlindType.BOSS: return "Boss Blind"
	return "Unknown"

func has_tag(tag: String) -> bool:
	return tags.has(tag)

func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": blind_type,
		"base_score": base_score
	}

static func from_dict(data: Dictionary) -> Blind:
	var blind = Blind.new()
	blind.id = data.get("id", "")
	blind.blind_type = data.get("type", BlindType.SMALL)
	blind.base_score = data.get("base_score", 200)
	return blind
