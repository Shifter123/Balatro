class_name ConsumableManager
extends Node

signal consumable_acquired(consumable: Consumable)
signal consumable_used(consumable: Consumable)
signal consumable_destroyed(consumable: Consumable)

var tarot_cards: Array[Consumable] = []
var planet_cards: Array[Consumable] = []
var spectral_cards: Array[Consumable] = []
var vouchers: Array[Consumable] = []

var _tarot_templates: Dictionary = {}
var _planet_templates: Dictionary = {}
var _spectral_templates: Dictionary = {}
var _voucher_templates: Dictionary = {}

func _init() -> void:
	pass

func _ready() -> void:
	_load_templates()

func _load_templates() -> void:
	_init_tarot_templates()
	_init_planet_templates()
	_init_voucher_templates()

func _init_tarot_templates() -> void:
	_tarot_templates = {
		"fool": {"name": "The Fool", "description": "Creates a copy of a random Joker", "type": Consumable.ConsumableType.TAROT},
		"magician": {"name": "The Magician", "description": "+2 Mult", "type": Consumable.ConsumableType.TAROT},
		"high_priestess": {"name": "The High Priestess", "description": "Creates a copy of a random Tarot card", "type": Consumable.ConsumableType.TAROT},
		"empress": {"name": "The Empress", "description": "+2 Chips", "type": Consumable.ConsumableType.TAROT},
		"emperor": {"name": "The Emperor", "description": "Creates a random rare Joker", "type": Consumable.ConsumableType.TAROT},
		"hierophant": {"name": "The Hierophant", "description": "+1 Joker slot", "type": Consumable.ConsumableType.TAROT},
		"lovers": {"name": "The Lovers", "description": "Converts 2 cards to random suits", "type": Consumable.ConsumableType.TAROT},
		"chariot": {"name": "The Chariot", "description": "+2 Mult, removes 1 random Joker", "type": Consumable.ConsumableType.TAROT},
		"strength": {"name": "Strength", "description": "+1 Card hand size, +2 Chips", "type": Consumable.ConsumableType.TAROT},
		"hermit": {"name": "The Hermit", "description": "Sell 1 Joker for $4 extra", "type": Consumable.ConsumableType.TAROT},
		"wheel_of_fortune": {"name": "Wheel of Fortune", "description": "Creates a random Joker", "type": Consumable.ConsumableType.TAROT},
		"justice": {"name": "Justice", "description": "+1 Mult", "type": Consumable.ConsumableType.TAROT},
		"hanged_man": {"name": "The Hanged Man", "description": "Destructively converts 1 card to random rank", "type": Consumable.ConsumableType.TAROT},
		"death": {"name": "Death", "description": "Converts 3 cards to random ranks", "type": Consumable.ConsumableType.TAROT},
		"temperance": {"name": "Temperance", "description": "+2 Joker slots", "type": Consumable.ConsumableType.TAROT},
		"tower": {"name": "The Tower", "description": "Creates 2 random Jokers", "type": Consumable.ConsumableType.TAROT},
		"star": {"name": "The Star", "description": "+4 Chips", "type": Consumable.ConsumableType.TAROT},
		"moon": {"name": "The Moon", "description": "+3 Mult", "type": Consumable.ConsumableType.TAROT},
		"sun": {"name": "The Sun", "description": "+2 Mult, +4 Chips", "type": Consumable.ConsumableType.TAROT},
		"judgement": {"name": "Judgement", "description": "Creates a random Joker", "type": Consumable.ConsumableType.TAROT},
		"world": {"name": "The World", "description": "+1 Mult, +1 Chips", "type": Consumable.ConsumableType.TAROT}
	}

func _init_planet_templates() -> void:
	_planet_templates = {
		"mercury": {"name": "Mercury", "description": "+3 Chips for High Card, Straight, Flush", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.HIGH_CARD, HandEvaluator.HandType.STRAIGHT, HandEvaluator.HandType.FLUSH]},
		"venus": {"name": "Venus", "description": "+2 Mult for Pair, Two Pair", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.ONE_PAIR, HandEvaluator.HandType.TWO_PAIR]},
		"earth": {"name": "Earth", "description": "+3 Mult for Three of a Kind", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.THREE_OF_A_KIND]},
		"mars": {"name": "Mars", "description": "+4 Mult for Straight", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.STRAIGHT]},
		"jupiter": {"name": "Jupiter", "description": "+2 Mult for Flush, Full House", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.FLUSH, HandEvaluator.HandType.FULL_HOUSE]},
		"saturn": {"name": "Saturn", "description": "+4 Chips for Straight, Flush", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.STRAIGHT, HandEvaluator.HandType.FLUSH]},
		"uranus": {"name": "Uranus", "description": "+4 Mult for Four of a Kind", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.FOUR_OF_A_KIND]},
		"neptune": {"name": "Neptune", "description": "+3 Mult for Straight Flush", "type": Consumable.ConsumableType.PLANET, "hand_types": [HandEvaluator.HandType.STRAIGHT_FLUSH]},
		"pluto": {"name": "Pluto", "description": "+1 Mult for any hand", "type": Consumable.ConsumableType.PLANET, "hand_types": []},
		"eris": {"name": "Eris", "description": "+1 Mult for any hand", "type": Consumable.ConsumableType.PLANET, "hand_types": []}
	}

func _init_voucher_templates() -> void:
	_voucher_templates = {
		"grabber": {"name": "Grabber", "description": "+1 Hand per round", "type": Consumable.ConsumableType.VOUCHER, "cost": 4},
		"hollow_one": {"name": "Hollow One", "description": "+1 Hand size", "type": Consumable.ConsumableType.VOUCHER, "cost": 4},
		"clearance": {"name": "Clearance", "description": "Jokers start with +1 Mult", "type": Consumable.ConsumableType.VOUCHER, "cost": 4},
		"drake_liver": {"name": "Drake Liver", "description": "+1 Joker slot", "type": Consumable.ConsumableType.VOUCHER, "cost": 4},
		"crystal_ball": {"name": "Crystal Ball", "description": "+1 Free Planet or Tarot card", "type": Consumable.ConsumableType.VOUCHER, "cost": 4},
		"ritual": {"name": "Ritual", "description": "+1 Joker slot", "type": Consumable.ConsumableType.VOUCHER, "cost": 4}
	}

func create_tarot_card(card_id: String) -> Consumable:
	if not _tarot_templates.has(card_id):
		return null
	
	var template = _tarot_templates[card_id]
	var card = Consumable.new()
	card.id = card_id
	card.name = template["name"]
	card.description = template["description"]
	card.consumable_type = Consumable.ConsumableType.TAROT
	card.cost = 3
	card.uses = 1
	card.current_uses = 1
	
	return card

func create_planet_card(card_id: String) -> Consumable:
	if not _planet_templates.has(card_id):
		return null
	
	var template = _planet_templates[card_id]
	var card = Consumable.new()
	card.id = card_id
	card.name = template["name"]
	card.description = template["description"]
	card.consumable_type = Consumable.ConsumableType.PLANET
	card.cost = 2
	card.uses = 1
	card.current_uses = 1
	card.effect_data = {"hand_types": template.get("hand_types", [])}
	
	return card

func acquire_tarot(card_id: String) -> Consumable:
	var card = create_tarot_card(card_id)
	if card:
		tarot_cards.append(card)
		consumable_acquired.emit(card)
	return card

func acquire_planet(card_id: String) -> Consumable:
	var card = create_planet_card(card_id)
	if card:
		planet_cards.append(card)
		consumable_acquired.emit(card)
	return card

func acquire_random_tarot() -> Consumable:
	var ids = _tarot_templates.keys()
	if ids.is_empty():
		return null
	var rng = Globals.rng
	var random_id = ids[rng.randi() % ids.size()]
	return acquire_tarot(random_id)

func acquire_random_planet() -> Consumable:
	var ids = _planet_templates.keys()
	if ids.is_empty():
		return null
	var rng = Globals.rng
	var random_id = ids[rng.randi() % ids.size()]
	return acquire_planet(random_id)

func use_tarot(index: int) -> bool:
	if index < 0 or index >= tarot_cards.size():
		return false
	var card = tarot_cards[index]
	if card.use():
		consumable_used.emit(card)
		if not card.has_uses():
			tarot_cards.remove_at(index)
			consumable_destroyed.emit(card)
		return true
	return false

func use_planet(index: int) -> bool:
	if index < 0 or index >= planet_cards.size():
		return false
	var card = planet_cards[index]
	if card.use():
		consumable_used.emit(card)
		if not card.has_uses():
			planet_cards.remove_at(index)
			consumable_destroyed.emit(card)
		return true
	return false

func get_tarot_count() -> int:
	return tarot_cards.size()

func get_planet_count() -> int:
	return planet_cards.size()

func clear_all() -> void:
	tarot_cards.clear()
	planet_cards.clear()
	spectral_cards.clear()

func to_dict() -> Dictionary:
	var tarot_ids: Array = []
	for card in tarot_cards:
		tarot_ids.append({"id": card.id, "uses": card.current_uses})
	
	var planet_ids: Array = []
	for card in planet_cards:
		planet_ids.append({"id": card.id, "uses": card.current_uses})
	
	return {
		"tarot": tarot_ids,
		"planet": planet_ids
	}

func from_dict(data: Dictionary) -> void:
	tarot_cards.clear()
	planet_cards.clear()
	
	if data.has("tarot"):
		for card_data in data["tarot"]:
			var card = create_tarot_card(card_data.get("id", ""))
			if card:
				card.current_uses = card_data.get("uses", 1)
				tarot_cards.append(card)
	
	if data.has("planet"):
		for card_data in data["planet"]:
			var card = create_planet_card(card_data.get("id", ""))
			if card:
				card.current_uses = card_data.get("uses", 1)
				planet_cards.append(card)
