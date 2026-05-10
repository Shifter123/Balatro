class_name Consumable
extends Node

enum ConsumableType {
	TAROT,
	PLANET,
	SPECTRAL,
	VOUCHER
}

signal consumable_used(consumable: Consumable)
signal consumable_destroyed(consumable: Consumable)

var id: String = ""
var name: String = ""
var description: String = ""
var consumable_type: ConsumableType = ConsumableType.TAROT

var cost: int = 3
var uses: int = 1
var current_uses: int = 1

var effect_data: Dictionary = {}

func _init() -> void:
	pass

func setup(p_id: String, p_name: String, p_description: String, p_type: ConsumableType, p_cost: int, p_uses: int = 1) -> void:
	id = p_id
	name = p_name
	description = p_description
	consumable_type = p_type
	cost = p_cost
	uses = p_uses
	current_uses = uses

func use(target: Variant = null) -> bool:
	if current_uses <= 0:
		return false
	
	current_uses -= 1
	consumable_used.emit(self)
	
	if current_uses <= 0:
		consumable_destroyed.emit(self)
		queue_free()
	
	return true

func get_display_name() -> String:
	return name

func get_uses_text() -> String:
	return "%d/%d" % [current_uses, uses]

func has_uses() -> bool:
	return current_uses > 0

func reset_uses() -> void:
	current_uses = uses

func copy() -> Consumable:
	var new_consumable = Consumable.new()
	new_consumable.id = id
	new_consumable.name = name
	new_consumable.description = description
	new_consumable.consumable_type = consumable_type
	new_consumable.cost = cost
	new_consumable.uses = uses
	new_consumable.current_uses = current_uses
	new_consumable.effect_data = effect_data.duplicate()
	return new_consumable

func to_dict() -> Dictionary:
	return {
		"id": id,
		"type": consumable_type,
		"uses": current_uses
	}

static func from_dict(data: Dictionary) -> Consumable:
	var consumable = Consumable.new()
	consumable.id = data.get("id", "")
	consumable.consumable_type = data.get("type", ConsumableType.TAROT)
	consumable.current_uses = data.get("uses", 1)
	return consumable
