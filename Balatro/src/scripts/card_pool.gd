class_name CardPool
extends Node

var _available_cards: Array[Card] = []
var _in_use_cards: Array[Card] = []
var _pool_size: int = 52

signal card_acquired(card: Card)
signal card_released(card: Card)

func _init(pool_size: int = 52) -> void:
	_pool_size = pool_size

func _ready() -> void:
	_initialize_pool()

func _initialize_pool() -> void:
	for i in range(_pool_size):
		var card = Card.new()
		card.set_process(false)
		_available_cards.append(card)
		add_child(card)

func acquire_card(suit: Globals.Suit, rank: Globals.CardRank) -> Card:
	var card: Card
	
	if _available_cards.is_empty():
		card = Card.new(suit, rank)
		add_child(card)
		_in_use_cards.append(card)
	else:
		card = _available_cards.pop_front()
		card.suit = suit
		card.rank = rank
		card.is_selected = false
		card.is_face_up = true
		card.id = card._generate_id()
		_in_use_cards.append(card)
	
	card.set_process(true)
	card_acquired.emit(card)
	return card

func acquire_card_from_data(card_data: Dictionary) -> Card:
	var card = acquire_card(card_data.get("suit", Globals.Suit.HEARTS), card_data.get("rank", Globals.CardRank.ACE))
	card.cost = card_data.get("cost", 0)
	card.is_face_up = card_data.get("is_face_up", true)
	return card

func release_card(card: Card) -> void:
	if not _in_use_cards.has(card):
		return
	
	_in_use_cards.erase(card)
	card.deselect()
	card.set_process(false)
	_available_cards.append(card)
	card_released.emit(card)

func release_all() -> void:
	var cards_to_release = _in_use_cards.duplicate()
	for card in cards_to_release:
		release_card(card)

func get_available_count() -> int:
	return _available_cards.size()

func get_in_use_count() -> int:
	return _in_use_cards.size()

func get_total_count() -> int:
	return _available_cards.size() + _in_use_cards.size()

func clear() -> void:
	release_all()
	for card in _available_cards:
		card.queue_free()
	_available_cards.clear()
	_in_use_cards.clear()
