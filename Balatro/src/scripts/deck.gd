class_name Deck
extends Node

signal deck_shuffled
signal card_drawn(card: Card)
signal cards_drawn(cards: Array[Card])

var cards: Array[Card] = []
var discard_pile: Array[Card] = []
var draw_count: int = 0

func _init() -> void:
	pass

func create_standard_deck() -> void:
	cards.clear()
	for suit in Globals.Suit.values():
		for rank in Globals.CardRank.values():
			var card = Card.new(suit, rank)
			cards.append(card)
	draw_count = 0

func shuffle() -> void:
	var rng = Globals.rng
	var shuffled: Array[Card] = []
	var remaining = cards.duplicate()
	
	while not remaining.is_empty():
		var index = rng.randi() % remaining.size()
		shuffled.append(remaining[index])
		remaining.remove_at(index)
	
	cards = shuffled
	draw_count = 0
	deck_shuffled.emit()

func draw(count: int = 1) -> Array[Card]:
	var drawn: Array[Card] = []
	for i in range(count):
		if cards.is_empty():
			if discard_pile.is_empty():
				break
			reshuffle_discard()
		if not cards.is_empty():
			var card = cards.pop_front()
			drawn.append(card)
			card_drawn.emit(card)
			draw_count += 1
	
	if not drawn.is_empty():
		cards_drawn.emit(drawn)
	return drawn

func reshuffle_discard() -> void:
	cards = discard_pile.duplicate()
	discard_pile.clear()
	shuffle()

func discard_card(card: Card) -> void:
	if cards.has(card):
		cards.erase(card)
	if not discard_pile.has(card):
		discard_pile.append(card)

func discard_hand(hand: Array[Card]) -> void:
	for card in hand:
		discard_card(card)

func return_to_deck(card: Card) -> void:
	if discard_pile.has(card):
		discard_pile.erase(card)
	if not cards.has(card):
		cards.append(card)

func get_remaining_count() -> int:
	return cards.size()

func get_discarded_count() -> int:
	return discard_pile.size()

func get_total_count() -> int:
	return cards.size() + discard_pile.size()

func reset() -> void:
	cards.clear()
	discard_pile.clear()
	draw_count = 0
