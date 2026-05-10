class_name Item
extends Node

enum Rarity {
	COMMON,
	UNCOMMON,
	RARE
}

enum ItemType {
	PERMANENT,
	CONSUMABLE,
	TEMPORARY
}

signal item_activated(item: Item)
signal item_sold
signal item_triggered(item: Item, trigger: String)

var id: String = ""
var name: String = ""
var description: String = ""
var rarity: Rarity = Rarity.COMMON
var item_type: ItemType = ItemType.PERMANENT

var cost: int = 4
var sell_value: int = 2

var is_equipped: bool = false
var is_active: bool = true

var effect_data: Dictionary = {}

func setup(p_id: String, p_name: String, p_description: String, p_rarity: Rarity, p_cost: int) -> void:
	id = p_id
	name = p_name
	description = p_description
	rarity = p_rarity
	cost = p_cost
	sell_value = ceili(float(cost) * 0.5)

func get_display_name() -> String:
	return name

func get_rarity_name() -> String:
	match rarity:
		Rarity.COMMON: return "Common"
		Rarity.UNCOMMON: return "Uncommon"
		Rarity.RARE: return "Rare"
	return "Unknown"

func get_rarity_color() -> Color:
	match rarity:
		Rarity.COMMON: return Color("#aaaaff")
		Rarity.UNCOMMON: return Color("#55ff55")
		Rarity.RARE: return Color("#ff55ff")
	return Color.WHITE

func activate() -> void:
	if not is_active:
		return
	item_activated.emit(self)

func sell() -> int:
	sold.emit()
	var value = sell_value
	queue_free()
	return value

func copy() -> Item:
	var new_item = Item.new()
	new_item.id = id
	new_item.name = name
	new_item.description = description
	new_item.rarity = rarity
	new_item.item_type = item_type
	new_item.cost = cost
	new_item.sell_value = sell_value
	new_item.effect_data = effect_data.duplicate()
	return new_item

func to_dict() -> Dictionary:
	return {
		"id": id,
		"rarity": rarity,
		"is_equipped": is_equipped
	}

static func from_dict(data: Dictionary) -> Item:
	var item = Item.new()
	item.id = data.get("id", "")
	item.rarity = data.get("rarity", Rarity.COMMON)
	item.is_equipped = data.get("is_equipped", false)
	return item
