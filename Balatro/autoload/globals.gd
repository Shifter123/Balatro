extends Node

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var game_version: String = "0.1.0"

enum Suit {
	HEARTS,
	DIAMONDS,
	CLUBS,
	SPADES
}

enum CardRank {
	ACE = 1,
	TWO = 2,
	THREE = 3,
	FOUR = 4,
	FIVE = 5,
	SIX = 6,
	SEVEN = 7,
	EIGHT = 8,
	NINE = 9,
	TEN = 10,
	JACK = 11,
	QUEEN = 12,
	KING = 13
}

const SUIT_SYMBOLS: Dictionary = {
	Suit.HEARTS: "♥",
	Suit.DIAMONDS: "♦",
	Suit.CLUBS: "♣",
	Suit.SPADES: "♠"
}

const SUIT_NAMES: Dictionary = {
	Suit.HEARTS: "Hearts",
	Suit.DIAMONDS: "Diamonds",
	Suit.CLUBS: "Clubs",
	Suit.SPADES: "Spades"
}

const RANK_NAMES: Dictionary = {
	CardRank.ACE: "A",
	CardRank.TWO: "2",
	CardRank.THREE: "3",
	CardRank.FOUR: "4",
	CardRank.FIVE: "5",
	CardRank.SIX: "6",
	CardRank.SEVEN: "7",
	CardRank.EIGHT: "8",
	CardRank.NINE: "9",
	CardRank.TEN: "10",
	CardRank.JACK: "J",
	CardRank.QUEEN: "Q",
	CardRank.KING: "K"
}

func _ready() -> void:
	rng.randomize()

func get_random_seed() -> int:
	return rng.randi()

func set_seed(seed_value: int) -> void:
	rng.seed = seed_value
