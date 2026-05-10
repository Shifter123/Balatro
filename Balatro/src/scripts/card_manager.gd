class_name CardManager
extends Node

var deck: Deck
var hand: Hand
var card_pool: CardPool

var _hand_size: int = 5

func _init() -> void:
	deck = Deck.new()
	hand = Hand.new(_hand_size)
	card_pool = CardPool.new(52)
	add_child(deck)
	add_child(hand)
	add_child(card_pool)

func setup_new_round() -> void:
	deck.create_standard_deck()
	deck.shuffle()
	hand.clear()
	card_pool.release_all()

func deal_initial_hand() -> Array[Card]:
	var drawn_cards = deck.draw(_hand_size)
	for card in drawn_cards:
		hand.add_card(card)
	return drawn_cards

func draw_cards(count: int) -> Array[Card]:
	var drawn_cards = deck.draw(count)
	for card in drawn_cards:
		hand.add_card(card)
	return drawn_cards

func play_card(card: Card) -> bool:
	if hand.remove_card(card):
		return true
	return false

func play_selected_cards() -> Array[Card]:
	var selected = hand.get_selected_cards()
	for card in selected:
		hand.remove_card(card)
	return selected

func discard_hand() -> void:
	var hand_cards = hand.get_cards()
	hand.clear()
	deck.discard_hand(hand_cards)

func discard_card(card: Card) -> void:
	if hand.remove_card(card):
		deck.discard_card(card)

func return_card_to_deck(card: Card) -> void:
	if hand.remove_card(card):
		deck.return_to_deck(card)

func get_hand_score_preview() -> int:
	var selected = hand.get_selected_cards()
	if selected.size() < _hand_size:
		selected = hand.get_cards()
	return 0

func get_deck_info() -> Dictionary:
	return {
		"remaining": deck.get_remaining_count(),
		"discarded": deck.get_discarded_count(),
		"total": deck.get_total_count()
	}

func get_hand_info() -> Dictionary:
	return {
		"cards": hand.get_size(),
		"max_size": hand.max_size,
		"selected_count": hand.get_selected_cards().size()
	}

func can_draw() -> bool:
	return deck.get_remaining_count() > 0 or deck.get_discarded_count() > 0

func can_play() -> bool:
	return hand.get_size() > 0
