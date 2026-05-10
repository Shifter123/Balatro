class_name JokerManager
extends Node

signal joker_acquired(joker: Joker)
signal joker_sold(joker: Joker)
signal joker_equipped(joker: Joker)
signal joker_unequipped(joker: Joker)
signal joker_triggered(joker: Joker, trigger: String, amount: float)
signal slot_changed(slot_count: int)

var owned_jokers: Array[Joker] = []
var equipped_jokers: Array[Joker] = []
var available_slots: int = 5

var _joker_templates: Dictionary = {}
var _joker_effects: Dictionary = {}

func _init() -> void:
	pass

func _ready() -> void:
	_load_joker_templates()

func _load_joker_templates() -> void:
	var file_path = "res://data/cards/jokers.json"
	if not FileAccess.file_exists(file_path):
		push_warning("Joker templates file not found: %s" % file_path)
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open joker templates: %s" % FileAccess.get_open_error())
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("Failed to parse joker templates JSON")
		return
	
	var data = json.data as Dictionary
	if data.has("jokers"):
		for joker_data in data["jokers"]:
			var id = joker_data.get("id", "")
			_joker_templates[id] = joker_data

func create_joker(joker_id: String) -> Joker:
	if not _joker_templates.has(joker_id):
		push_warning("Joker template not found: %s" % joker_id)
		return null
	
	var template = _joker_templates[joker_id]
	var joker = Joker.new()
	
	joker.id = template.get("id", joker_id)
	joker.name = template.get("name", "Unknown Joker")
	joker.description = template.get("description", "")
	joker.cost = template.get("cost", 4)
	
	var rarity_str = template.get("rarity", "common")
	match rarity_str:
		"common": joker.rarity = Joker.Rarity.COMMON
		"uncommon": joker.rarity = Joker.Rarity.UNCOMMON
		"rare": joker.rarity = Joker.Rarity.RARE
		"legendary": joker.rarity = Joker.Rarity.LEGENDARY
	
	var type_str = template.get("type", "score_boost")
	match type_str:
		"score_boost": joker.joker_type = Joker.JokerType.SCORE_BOOST
		"multiplier": joker.joker_type = Joker.JokerType.MULTIPLIER
		"economy": joker.joker_type = Joker.JokerType.ECONOMY
		"utility": joker.joker_type = Joker.JokerType.UTILITY
		"special": joker.joker_type = Joker.JokerType.SPECIAL
	
	if template.has("effect"):
		var effect = template["effect"]
		joker.base_value = effect.get("value", 0.0)
		_joker_effects[joker.id] = effect
	
	return joker

func acquire_joker(joker_id: String) -> Joker:
	var joker = create_joker(joker_id)
	if joker == null:
		return null
	
	owned_jokers.append(joker)
	joker_acquired.emit(joker)
	return joker

func equip_joker(joker: Joker) -> bool:
	var required_slots = joker.slots_required
	var current_used = get_used_slots()
	
	if current_used + required_slots > available_slots:
		return false
	
	if not owned_jokers.has(joker):
		return false
	
	if equipped_jokers.has(joker):
		return false
	
	equipped_jokers.append(joker)
	joker.equip()
	slot_changed.emit(available_slots - get_used_slots())
	joker_equipped.emit(joker)
	return true

func unequip_joker(joker: Joker) -> bool:
	if not equipped_jokers.has(joker):
		return false
	
	equipped_jokers.erase(joker)
	joker.unequip()
	slot_changed.emit(available_slots - get_used_slots())
	joker_unequipped.emit(joker)
	return true

func sell_joker(joker: Joker) -> int:
	if equipped_jokers.has(joker):
		unequip_joker(joker)
	
	if owned_jokers.has(joker):
		owned_jokers.erase(joker)
		var value = joker.get_sell_value()
		joker.sell()
		joker_sold.emit(joker)
		return value
	
	return 0

func get_available_slots() -> int:
	return available_slots - get_used_slots()

func get_used_slots() -> int:
	var used = 0
	for joker in equipped_jokers:
		used += joker.slots_required
	return used

func calculate_total_bonus(cards: Array[Card], hand_result: Dictionary) -> Dictionary:
	var total_mult: float = 1.0
	var total_chips: int = 0
	var bonus_score: int = 0
	
	for joker in equipped_jokers:
		if not joker.is_active:
			continue
		
		var effect = _joker_effects.get(joker.id, {})
		var result = _calculate_joker_effect(joker, effect, cards, hand_result)
		
		total_mult *= result.get("mult_mult", 1.0)
		total_chips += result.get("chip_add", 0)
		bonus_score += result.get("score_add", 0)
		
		if result.get("triggered", false):
			joker_triggered.emit(joker, result.get("trigger_type", ""), result.get("trigger_amount", 0.0))
	
	return {
		"mult": total_mult,
		"chips": total_chips,
		"bonus_score": bonus_score
	}

func _calculate_joker_effect(joker: Joker, effect: Dictionary, cards: Array[Card], hand_result: Dictionary) -> Dictionary:
	var effect_type = effect.get("type", "")
	
	match effect_type:
		"mult_add":
			return {"mult_mult": 1.0, "chip_add": 0, "score_add": effect.get("value", 0), "triggered": true, "trigger_type": "mult_add"}
		
		"chip_add":
			return {"mult_mult": 1.0, "chip_add": effect.get("value", 0), "score_add": 0}
		
		"mult_multiply":
			return {"mult_mult": effect.get("value", 1.0), "chip_add": 0, "score_add": 0}
		
		"mult_per_card":
			var count = cards.size()
			var mult = effect.get("value", 1) * count
			return {"mult_mult": 1.0, "chip_add": 0, "score_add": mult, "triggered": true}
		
		"mult_per_rank":
			var rank = effect.get("rank", 1)
			var mult = effect.get("value", 1)
			var count = _count_cards_by_rank(cards, rank)
			return {"mult_mult": 1.0, "chip_add": 0, "score_add": mult * count}
		
		"mult_per_suit":
			var suit_str = effect.get("suit", "hearts")
			var suit = _get_suit_from_string(suit_str)
			var mult = effect.get("value", 1)
			var count = _count_cards_by_suit(cards, suit)
			return {"mult_mult": 1.0, "chip_add": 0, "score_add": mult * count}
		
		"chip_per_rank":
			var ranks = effect.get("ranks", [])
			var chip_value = effect.get("value", 1)
			var count = 0
			for rank in ranks:
				count += _count_cards_by_rank(cards, rank)
			return {"mult_mult": 1.0, "chip_add": chip_value * count, "score_add": 0}
		
		"chance_mult":
			var chance = effect.get("chance", 0.5)
			var mult_value = effect.get("mult", 2.0)
			if randf() < chance:
				return {"mult_mult": mult_value, "chip_add": 0, "score_add": 0, "triggered": true, "trigger_type": "lucky"}
			return {"mult_mult": 1.0, "chip_add": 0, "score_add": 0}
		
		"conditional_mult":
			var conditions = effect.get("conditions", [])
			var value = effect.get("value", 1)
			var hand_type = hand_result.get("type", -1)
			
			var triggered = false
			if conditions.has("flush") and hand_type == HandEvaluator.HandType.FLUSH:
				triggered = true
			if conditions.has("straight") and hand_type == HandEvaluator.HandType.STRAIGHT:
				triggered = true
			
			if triggered:
				return {"mult_mult": 1.0, "chip_add": 0, "score_add": value, "triggered": true}
		
		"mult_per_face":
			var count = 0
			for card in cards:
				if card.rank >= Globals.CardRank.JACK:
					count += 1
			return {"mult_mult": 1.0, "chip_add": 0, "score_add": effect.get("value", 1) * count}
		
		"mult_per_even":
			var count = 0
			for card in cards:
				if card.rank % 2 == 0:
					count += 1
			return {"mult_mult": 1.0, "chip_add": 0, "score_add": effect.get("value", 1) * count}
		
		"chip_per_odd":
			var count = 0
			for card in cards:
				if card.rank % 2 == 1:
					count += 1
			return {"mult_mult": 1.0, "chip_add": effect.get("value", 1) * count, "score_add": 0}
	
	return {"mult_mult": 1.0, "chip_add": 0, "score_add": 0}

func _count_cards_by_rank(cards: Array[Card], rank: Globals.CardRank) -> int:
	var count = 0
	for card in cards:
		if card.rank == rank:
			count += 1
	return count

func _count_cards_by_suit(cards: Array[Card], suit: Globals.Suit) -> int:
	var count = 0
	for card in cards:
		if card.suit == suit:
			count += 1
	return count

func _get_suit_from_string(suit_str: String) -> Globals.Suit:
	match suit_str.to_lower():
		"hearts": return Globals.Suit.HEARTS
		"diamonds": return Globals.Suit.DIAMONDS
		"clubs": return Globals.Suit.CLUBS
		"spades": return Globals.Suit.SPADES
	return Globals.Suit.HEARTS

func set_available_slots(count: int) -> void:
	available_slots = maxi(1, count)
	slot_changed.emit(get_available_slots())

func reset_round() -> void:
	for joker in equipped_jokers:
		pass

func get_owned_count() -> int:
	return owned_jokers.size()

func get_equipped_count() -> int:
	return equipped_jokers.size()

func to_dict() -> Dictionary:
	var owned_ids: Array = []
	for joker in owned_jokers:
		owned_ids.append(joker.id)
	
	var equipped_ids: Array = []
	for joker in equipped_jokers:
		equipped_ids.append(joker.id)
	
	return {
		"owned": owned_ids,
		"equipped": equipped_ids,
		"slots": available_slots
	}

func from_dict(data: Dictionary) -> void:
	owned_jokers.clear()
	equipped_jokers.clear()
	
	if data.has("slots"):
		available_slots = data["slots"]
	
	if data.has("owned"):
		for id in data["owned"]:
			var joker = create_joker(id)
			if joker:
				owned_jokers.append(joker)
	
	if data.has("equipped"):
		for id in data["equipped"]:
			for joker in owned_jokers:
				if joker.id == id:
					equipped_jokers.append(joker)
					joker.equip()
					break
