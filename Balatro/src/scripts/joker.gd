class_name Joker
extends Node

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

enum JokerType {
	SCORE_BOOST,
	MULTIPLIER,
	ECONOMY,
	UTILITY,
	SPECIAL
}

signal joker_activated(trigger: String, amount: float)
signal joker_sold
signal joker_equipped
signal joker_unequipped

var id: String = ""
var name: String = ""
var description: String = ""
var rarity: Rarity = Rarity.COMMON
var joker_type: JokerType = JokerType.SCORE_BOOST

var cost: int = 4
var sell_value: int = 2
var slots_required: int = 1

var is_equipped: bool = false
var is_active: bool = true

var base_value: float = 0.0
var current_value: float = 0.0

var trigger_condition: String = ""
var trigger_target: String = ""

func _init() -> void:
	pass

func setup(p_id: String, p_name: String, p_description: String, p_rarity: Rarity, p_cost: int) -> void:
	id = p_id
	name = p_name
	description = p_description
	rarity = p_rarity
	cost = p_cost
	sell_value = ceili(float(cost) * 0.5)
	current_value = base_value

func get_display_name() -> String:
	return name

func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON: return "Common"
		Rarity.UNCOMMON: return "Uncommon"
		Rarity.RARE: return "Rare"
		Rarity.LEGENDARY: return "Legendary"
	return "Unknown"

func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color("#aaaaff")
		Rarity.UNCOMMON: return Color("#55ff55")
		Rarity.RARE: return Color("#ff55ff")
		Rarity.LEGENDARY: return Color("#ffaa00")
	return Color.WHITE

func get_sell_value() -> int:
	return sell_value

func get_cost() -> int:
	return cost

func sell() -> void:
	sold.emit()
	queue_free()

func activate(trigger: String, amount: float = 0.0) -> void:
	if not is_active:
		return
	joker_activated.emit(trigger, amount)

func equip() -> void:
	is_equipped = true
	joker_equipped.emit()

func unequip() -> void:
	is_equipped = false
	joker_unequipped.emit()

func get_effect_description() -> String:
	return description

func calculate_score(base_score: int, mult: int) -> Dictionary:
	return {"score": base_score, "mult": mult, "bonus": 0}

func copy() -> Joker:
	var new_joker = Joker.new()
	new_joker.id = id
	new_joker.name = name
	new_joker.description = description
	new_joker.rarity = rarity
	new_joker.joker_type = joker_type
	new_joker.cost = cost
	new_joker.sell_value = sell_value
	new_joker.slots_required = slots_required
	new_joker.base_value = base_value
	new_joker.current_value = current_value
	new_joker.trigger_condition = trigger_condition
	new_joker.trigger_target = trigger_target
	return new_joker

func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"rarity": rarity,
		"cost": cost
	}

static func from_dict(data: Dictionary) -> Joker:
	var joker = Joker.new()
	joker.id = data.get("id", "")
	joker.name = data.get("name", "")
	joker.description = data.get("description", "")
	joker.rarity = data.get("rarity", Rarity.COMMON)
	joker.cost = data.get("cost", 4)
	return joker
