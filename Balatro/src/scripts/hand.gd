class_name Hand
extends Node

signal hand_changed
signal hand_discarded

var cards: Array[Card] = []
var max_size: int = 5

func _init(size: int = 5) -> void:
	max_size = size

func add_card(card: Card) -> bool:
	if cards.size() >= max_size:
		return false
	cards.append(card)
	hand_changed.emit()
	return true

func remove_card(card: Card) -> bool:
	if cards.has(card):
		cards.erase(card)
		hand_changed.emit()
		return true
	return false

func remove_card_at(index: int) -> Card:
	if index < 0 or index >= cards.size():
		return null
	var card = cards[index]
	cards.remove_at(index)
	hand_changed.emit()
	return card

func get_card(index: int) -> Card:
	if index < 0 or index >= cards.size():
		return null
	return cards[index]

func get_cards() -> Array[Card]:
	return cards.duplicate()

func clear() -> void:
	cards.clear()
	hand_changed.emit()

func is_full() -> bool:
	return cards.size() >= max_size

func is_empty() -> bool:
	return cards.is_empty()

func get_size() -> int:
	return cards.size()

func get_sorted_by_rank() -> Array[Card]:
	var sorted = cards.duplicate()
	sorted.sort_custom(func(a, b): return a.rank < b.rank)
	return sorted

func get_sorted_by_suit() -> Array[Card]:
	var sorted = cards.duplicate()
	sorted.sort_custom(func(a, b): return a.suit < b.suit)
	return sorted

func contains_suit(suit: Globals.Suit) -> bool:
	for card in cards:
		if card.suit == suit:
			return true
	return false

func contains_rank(rank: Globals.CardRank) -> bool:
	for card in cards:
		if card.rank == rank:
			return true
	return false

func get_cards_by_suit(suit: Globals.Suit) -> Array[Card]:
	var result: Array[Card] = []
	for card in cards:
		if card.suit == suit:
			result.append(card)
	return result

func get_cards_by_rank(rank: Globals.CardRank) -> Array[Card]:
	var result: Array[Card] = []
	for card in cards:
		if card.rank == rank:
			result.append(card)
	return result

func get_selected_cards() -> Array[Card]:
	var selected: Array[Card] = []
	for card in cards:
		if card.is_selected:
			selected.append(card)
	return selected

func deselect_all() -> void:
	for card in cards:
		card.deselect()

func select_all() -> void:
	for card in cards:
		card.select()
