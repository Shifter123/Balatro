class_name Card
extends Node

var id: String = ""
var suit: Globals.Suit
var rank: Globals.CardRank
var cost: int = 0
var is_face_up: bool = true
var is_selected: bool = false

signal card_selected(card: Card)
signal card_deselected(card: Card)

func _init(p_suit: Globals.Suit = Globals.Suit.HEARTS, p_rank: Globals.CardRank = Globals.CardRank.ACE) -> void:
	self.suit = p_suit
	self.rank = p_rank
	self.id = _generate_id()

func _generate_id() -> String:
	return "%s_%d" % [Globals.SUIT_NAMES[suit].to_lower(), rank]

func get_display_name() -> String:
	return "%s of %s" % [Globals.RANK_NAMES[rank], Globals.SUIT_NAMES[suit]]

func get_short_name() -> String:
	return "%s%s" % [Globals.RANK_NAMES[rank], Globals.SUIT_SYMBOLS[suit]]

func get_suit_color() -> Color:
	match suit:
		Globals.Suit.HEARTS, Globals.Suit.DIAMONDS:
			return Color.RED
		Globals.Suit.CLUBS, Globals.Suit.SPADES:
			return Color.BLACK
	return Color.WHITE

func get_base_value() -> int:
	return mini(rank, 10)

func select() -> void:
	if not is_selected:
		is_selected = true
		card_selected.emit(self)

func deselect() -> void:
	if is_selected:
		is_selected = false
		card_deselected.emit(self)

func toggle_selection() -> void:
	if is_selected:
		deselect()
	else:
		select()

func copy() -> Card:
	var new_card = Card.new(suit, rank)
	new_card.cost = cost
	new_card.is_face_up = is_face_up
	return new_card

func equals(other: Card) -> bool:
	if other == null:
		return false
	return suit == other.suit and rank == other.rank

func to_dict() -> Dictionary:
	return {
		"id": id,
		"suit": suit,
		"rank": rank,
		"cost": cost,
		"is_face_up": is_face_up
	}

static func from_dict(data: Dictionary) -> Card:
	var card = Card.new(
		data.get("suit", Globals.Suit.HEARTS),
		data.get("rank", Globals.CardRank.ACE)
	)
	card.id = data.get("id", card.id)
	card.cost = data.get("cost", 0)
	card.is_face_up = data.get("is_face_up", true)
	return card
