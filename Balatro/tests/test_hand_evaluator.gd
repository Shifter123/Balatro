extends TestSuite

const CARD_A: Globals.CardRank = Globals.CardRank.ACE
const CARD_K: Globals.CardRank = Globals.CardRank.KING
const CARD_Q: Globals.CardRank = Globals.CardRank.QUEEN
const CARD_J: Globals.CardRank = Globals.CardRank.JACK
const CARD_10: Globals.CardRank = Globals.CardRank.TEN
const CARD_9: Globals.CardRank = Globals.CardRank.NINE
const CARD_8: Globals.CardRank = Globals.CardRank.EIGHT
const CARD_7: Globals.CardRank = Globals.CardRank.SEVEN
const CARD_6: Globals.CardRank = Globals.CardRank.SIX
const CARD_5: Globals.CardRank = Globals.CardRank.FIVE
const CARD_4: Globals.CardRank = Globals.CardRank.FOUR
const CARD_3: Globals.CardRank = Globals.CardRank.THREE
const CARD_2: Globals.CardRank = Globals.CardRank.TWO

func test_high_card():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_7),
		Card.new(Globals.Suit.SPADES, CARD_K),
		Card.new(Globals.Suit.CLUBS, CARD_3),
		Card.new(Globals.Suit.DIAMONDS, CARD_J),
		Card.new(Globals.Suit.HEARTS, CARD_5)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.HIGH_CARD)
	assert_eq(result["cards"].size(), 5)

func test_one_pair():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.SPADES, CARD_K),
		Card.new(Globals.Suit.CLUBS, CARD_3),
		Card.new(Globals.Suit.DIAMONDS, CARD_J),
		Card.new(Globals.Suit.HEARTS, CARD_5)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.ONE_PAIR)

func test_two_pair():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.SPADES, CARD_K),
		Card.new(Globals.Suit.CLUBS, CARD_3),
		Card.new(Globals.Suit.DIAMONDS, CARD_3),
		Card.new(Globals.Suit.HEARTS, CARD_5)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.TWO_PAIR)

func test_three_of_a_kind():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.SPADES, CARD_K),
		Card.new(Globals.Suit.CLUBS, CARD_K),
		Card.new(Globals.Suit.DIAMONDS, CARD_3),
		Card.new(Globals.Suit.HEARTS, CARD_5)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.THREE_OF_A_KIND)

func test_straight():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_9),
		Card.new(Globals.Suit.SPADES, CARD_8),
		Card.new(Globals.Suit.CLUBS, CARD_7),
		Card.new(Globals.Suit.DIAMONDS, CARD_6),
		Card.new(Globals.Suit.HEARTS, CARD_5)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.STRAIGHT)

func test_flush():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.HEARTS, CARD_8),
		Card.new(Globals.Suit.HEARTS, CARD_7),
		Card.new(Globals.Suit.HEARTS, CARD_4),
		Card.new(Globals.Suit.HEARTS, CARD_2)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.FLUSH)

func test_full_house():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.SPADES, CARD_K),
		Card.new(Globals.Suit.CLUBS, CARD_K),
		Card.new(Globals.Suit.DIAMONDS, CARD_3),
		Card.new(Globals.Suit.HEARTS, CARD_3)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.FULL_HOUSE)

func test_four_of_a_kind():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.SPADES, CARD_K),
		Card.new(Globals.Suit.CLUBS, CARD_K),
		Card.new(Globals.Suit.DIAMONDS, CARD_K),
		Card.new(Globals.Suit.HEARTS, CARD_3)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.FOUR_OF_A_KIND)

func test_straight_flush():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_9),
		Card.new(Globals.Suit.HEARTS, CARD_8),
		Card.new(Globals.Suit.HEARTS, CARD_7),
		Card.new(Globals.Suit.HEARTS, CARD_6),
		Card.new(Globals.Suit.HEARTS, CARD_5)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.STRAIGHT_FLUSH)

func test_royal_flush():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_A),
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.HEARTS, CARD_Q),
		Card.new(Globals.Suit.HEARTS, CARD_J),
		Card.new(Globals.Suit.HEARTS, CARD_10)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.ROYAL_FLUSH)

func test_ace_low_straight():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_A),
		Card.new(Globals.Suit.SPADES, CARD_5),
		Card.new(Globals.Suit.CLUBS, CARD_4),
		Card.new(Globals.Suit.DIAMONDS, CARD_3),
		Card.new(Globals.Suit.HEARTS, CARD_2)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.STRAIGHT)

func test_hand_score_calculation():
	var cards = [
		Card.new(Globals.Suit.HEARTS, CARD_K),
		Card.new(Globals.Suit.SPADES, CARD_K),
		Card.new(Globals.Suit.CLUBS, CARD_K),
		Card.new(Globals.Suit.DIAMONDS, CARD_3),
		Card.new(Globals.Suit.HEARTS, CARD_3)
	]
	var result = HandEvaluator.evaluate_hand(cards)
	assert_eq(result["type"], HandEvaluator.HandType.FULL_HOUSE)
	assert_eq(result["chips"], 3 + 3 + 3 + 3 + 3)
	assert_eq(result["mult"], 4)
	assert_eq(result["score"], result["chips"] * result["mult"])
