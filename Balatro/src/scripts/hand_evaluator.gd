extends Node

enum HandType {
	HIGH_CARD = 0,
	ONE_PAIR = 1,
	TWO_PAIR = 2,
	THREE_OF_A_KIND = 3,
	STRAIGHT = 4,
	FLUSH = 5,
	FULL_HOUSE = 6,
	FOUR_OF_A_KIND = 7,
	STRAIGHT_FLUSH = 8,
	ROYAL_FLUSH = 9
}

const HAND_NAMES: Dictionary = {
	HandType.HIGH_CARD: "High Card",
	HandType.ONE_PAIR: "One Pair",
	HandType.TWO_PAIR: "Two Pair",
	HandType.THREE_OF_A_KIND: "Three of a Kind",
	HandType.STRAIGHT: "Straight",
	HandType.FLUSH: "Flush",
	HandType.FULL_HOUSE: "Full House",
	HandType.FOUR_OF_A_KIND: "Four of a Kind",
	HandType.STRAIGHT_FLUSH: "Straight Flush",
	HandType.ROYAL_FLUSH: "Royal Flush"
}

const BASE_SCORES: Dictionary = {
	HandType.HIGH_CARD: 5,
	HandType.ONE_PAIR: 10,
	HandType.TWO_PAIR: 15,
	HandType.THREE_OF_A_KIND: 20,
	HandType.STRAIGHT: 30,
	HandType.FLUSH: 35,
	HandType.FULL_HOUSE: 40,
	HandType.FOUR_OF_A_KIND: 60,
	HandType.STRAIGHT_FLUSH: 75,
	HandType.ROYAL_FLUSH: 100
}

const MULTIPLIERS: Dictionary = {
	HandType.HIGH_CARD: 1,
	HandType.ONE_PAIR: 1,
	HandType.TWO_PAIR: 2,
	HandType.THREE_OF_A_KIND: 3,
	HandType.STRAIGHT: 4,
	HandType.FLUSH: 4,
	HandType.FULL_HOUSE: 4,
	HandType.FOUR_OF_A_KIND: 6,
	HandType.STRAIGHT_FLUSH: 8,
	HandType.ROYAL_FLUSH: 8
}

static func evaluate_hand(cards: Array[Card]) -> Dictionary:
	if cards.size() < 5:
		return {
			"type": HandType.HIGH_CARD,
			"hand_name": HAND_NAMES[HandType.HIGH_CARD],
			"base_score": 0,
			"chips": 0,
			"mult": 1,
			"cards": cards
		}
	
	var result = _evaluate(cards)
	result["hand_name"] = HAND_NAMES[result["type"]]
	result["base_score"] = BASE_SCORES[result["type"]]
	result["chips"] = _calculate_chips(cards, result)
	result["mult"] = MULTIPLIERS[result["type"]]
	result["score"] = result["chips"] * result["mult"]
	return result

static func _evaluate(cards: Array[Card]) -> Dictionary:
	var royal_flush_result = _check_royal_flush(cards)
	if royal_flush_result["found"]:
		return royal_flush_result
	
	var straight_flush_result = _check_straight_flush(cards)
	if straight_flush_result["found"]:
		return straight_flush_result
	
	var four_of_kind_result = _check_four_of_a_kind(cards)
	if four_of_kind_result["found"]:
		return four_of_kind_result
	
	var full_house_result = _check_full_house(cards)
	if full_house_result["found"]:
		return full_house_result
	
	var flush_result = _check_flush(cards)
	if flush_result["found"]:
		return flush_result
	
	var straight_result = _check_straight(cards)
	if straight_result["found"]:
		return straight_result
	
	var three_of_kind_result = _check_three_of_a_kind(cards)
	if three_of_kind_result["found"]:
		return three_of_kind_result
	
	var two_pair_result = _check_two_pair(cards)
	if two_pair_result["found"]:
		return two_pair_result
	
	var one_pair_result = _check_one_pair(cards)
	if one_pair_result["found"]:
		return one_pair_result
	
	return _high_card(cards)

static func _check_royal_flush(cards: Array[Card]) -> Dictionary:
	var flush_result = _check_flush(cards)
	if not flush_result["found"]:
		return {"found": false}
	
	var suit = flush_result["suit"]
	var flush_cards = flush_result["cards"].duplicate()
	flush_cards.sort_custom(_sort_by_rank_desc)
	
	var expected_ranks = [
		Globals.CardRank.ACE,
		Globals.CardRank.KING,
		Globals.CardRank.QUEEN,
		Globals.CardRank.JACK,
		Globals.CardRank.TEN
	]
	
	var is_royal = true
	for i in range(mini(flush_cards.size(), 5)):
		if flush_cards[i].rank != expected_ranks[i]:
			is_royal = false
			break
	
	if is_royal:
		return {
			"found": true,
			"type": HandType.ROYAL_FLUSH,
			"cards": flush_cards.slice(0, 5)
		}
	
	return {"found": false}

static func _check_straight_flush(cards: Array[Card]) -> Dictionary:
	var flush_result = _check_flush(cards)
	if not flush_result["found"]:
		return {"found": false}
	
	var suit = flush_result["suit"]
	var flush_cards = flush_result["cards"].duplicate()
	
	var straight_result = _check_straight_internal(flush_cards)
	if straight_result["found"]:
		return {
			"found": true,
			"type": HandType.STRAIGHT_FLUSH,
			"cards": straight_result["cards"]
		}
	
	return {"found": false}

static func _check_four_of_a_kind(cards: Array[Card]) -> Dictionary:
	var rank_counts = _count_ranks(cards)
	
	for rank in rank_counts:
		if rank_counts[rank] >= 4:
			var four_cards: Array[Card] = []
			var kickers: Array[Card] = []
			
			for card in cards:
				if card.rank == rank:
					four_cards.append(card)
				else:
					kickers.append(card)
			
			four_cards.sort_custom(_sort_by_rank_desc)
			kickers.sort_custom(_sort_by_rank_desc)
			
			var result_cards = four_cards.slice(0, 4)
			if not kickers.is_empty():
				result_cards.append(kickers[0])
			
			return {
				"found": true,
				"type": HandType.FOUR_OF_A_KIND,
				"cards": result_cards
			}
	
	return {"found": false}

static func _check_full_house(cards: Array[Card]) -> Dictionary:
	var rank_counts = _count_ranks(cards)
	
	var three_rank: Globals.CardRank = -1
	var two_rank: Globals.CardRank = -1
	var three_count: int = 0
	var two_count: int = 0
	
	for rank in rank_counts:
		if rank_counts[rank] >= 3 and rank > three_rank:
			three_rank = rank
			three_count = rank_counts[rank]
	
	if three_rank < 0:
		return {"found": false}
	
	for rank in rank_counts:
		if rank != three_rank and rank_counts[rank] >= 2 and rank > two_rank:
			two_rank = rank
			two_count = rank_counts[rank]
	
	if two_rank < 0:
		return {"found": false}
	
	var result_cards: Array[Card] = []
	
	for card in cards:
		if card.rank == three_rank:
			result_cards.append(card)
		elif card.rank == two_rank and result_cards.size() < 5:
			result_cards.append(card)
	
	return {
		"found": true,
		"type": HandType.FULL_HOUSE,
		"cards": result_cards.slice(0, 5)
	}

static func _check_flush(cards: Array[Card]) -> Dictionary:
	var suit_counts: Dictionary = {}
	
	for card in cards:
		if not suit_counts.has(card.suit):
			suit_counts[card.suit] = []
		suit_counts[card.suit][card.suit].append(card)
	
	for suit in suit_counts:
		if suit_counts[suit].size() >= 5:
			var flush_cards = suit_counts[suit]
			flush_cards.sort_custom(_sort_by_rank_desc)
			return {
				"found": true,
				"suit": suit,
				"cards": flush_cards.slice(0, 5)
			}
	
	return {"found": false}

static func _check_straight(cards: Array[Card]) -> Dictionary:
	return _check_straight_internal(cards)

static func _check_straight_internal(cards: Array[Card]) -> Dictionary:
	var unique_cards = _get_unique_by_rank(cards)
	unique_cards.sort_custom(_sort_by_rank_desc)
	
	if unique_cards.size() < 5:
		return {"found": false}
	
	for i in range(unique_cards.size() - 4):
		var straight_cards = unique_cards.slice(i, i + 5)
		if _is_consecutive(straight_cards):
			return {
				"found": true,
				"cards": straight_cards
			}
	
	var wheel_cards = _check_ace_low_straight(unique_cards)
	if wheel_cards.size() == 5:
		return {
			"found": true,
			"cards": wheel_cards
		}
	
	return {"found": false}

static func _check_ace_low_straight(cards: Array[Card]) -> Array[Card]:
	var ace_cards: Array[Card] = []
	var other_cards: Array[Card] = []
	
	for card in cards:
		if card.rank == Globals.CardRank.ACE:
			ace_cards.append(card)
		else:
			other_cards.append(card)
	
	if ace_cards.size() == 0:
		return []
	
	var has_two = false
	var has_three = false
	var has_four = false
	var has_five = false
	
	for card in other_cards:
		match card.rank:
			Globals.CardRank.TWO: has_two = true
			Globals.CardRank.THREE: has_three = true
			Globals.CardRank.FOUR: has_four = true
			Globals.CardRank.FIVE: has_five = true
	
	if has_two and has_three and has_four and has_five:
		var result: Array[Card] = [ace_cards[0]]
		for card in other_cards:
			match card.rank:
				Globals.CardRank.FIVE, Globals.CardRank.FOUR, Globals.CardRank.THREE, Globals.CardRank.TWO:
					result.append(card)
					if result.size() >= 5:
						break
		if result.size() == 5:
			return result
	
	return []

static func _check_three_of_a_kind(cards: Array[Card]) -> Dictionary:
	var rank_counts = _count_ranks(cards)
	
	var three_rank: Globals.CardRank = -1
	for rank in rank_counts:
		if rank_counts[rank] >= 3 and rank > three_rank:
			three_rank = rank
	
	if three_rank < 0:
		return {"found": false}
	
	var three_cards: Array[Card] = []
	var kickers: Array[Card] = []
	
	for card in cards:
		if card.rank == three_rank:
			three_cards.append(card)
		else:
			kickers.append(card)
	
	three_cards.sort_custom(_sort_by_rank_desc)
	kickers.sort_custom(_sort_by_rank_desc)
	
	var result_cards = three_cards.slice(0, 3)
	if kickers.size() >= 2:
		result_cards.append(kickers[0])
		result_cards.append(kickers[1])
	elif kickers.size() == 1:
		result_cards.append(kickers[0])
	
	return {
		"found": true,
		"type": HandType.THREE_OF_A_KIND,
		"cards": result_cards
	}

static func _check_two_pair(cards: Array[Card]) -> Dictionary:
	var rank_counts = _count_ranks(cards)
	
	var pairs: Array[Globals.CardRank] = []
	for rank in rank_counts:
		if rank_counts[rank] >= 2:
			pairs.append(rank)
	
	if pairs.size() < 2:
		return {"found": false}
	
	pairs.sort_custom(func(a, b): return a > b)
	
	var pair1_rank = pairs[0]
	var pair2_rank = pairs[1]
	
	var pair1_cards: Array[Card] = []
	var pair2_cards: Array[Card] = []
	var kickers: Array[Card] = []
	
	for card in cards:
		if card.rank == pair1_rank and pair1_cards.size() < 2:
			pair1_cards.append(card)
		elif card.rank == pair2_rank and pair2_cards.size() < 2:
			pair2_cards.append(card)
		else:
			kickers.append(card)
	
	kickers.sort_custom(_sort_by_rank_desc)
	
	var result_cards: Array[Card] = []
	result_cards.append(pair1_cards[0])
	result_cards.append(pair1_cards[1])
	result_cards.append(pair2_cards[0])
	result_cards.append(pair2_cards[1])
	if not kickers.is_empty():
		result_cards.append(kickers[0])
	
	return {
		"found": true,
		"type": HandType.TWO_PAIR,
		"cards": result_cards
	}

static func _check_one_pair(cards: Array[Card]) -> Dictionary:
	var rank_counts = _count_ranks(cards)
	
	var pair_rank: Globals.CardRank = -1
	for rank in rank_counts:
		if rank_counts[rank] >= 2 and rank > pair_rank:
			pair_rank = rank
	
	if pair_rank < 0:
		return {"found": false}
	
	var pair_cards: Array[Card] = []
	var kickers: Array[Card] = []
	
	for card in cards:
		if card.rank == pair_rank:
			pair_cards.append(card)
		else:
			kickers.append(card)
	
	pair_cards.sort_custom(_sort_by_rank_desc)
	kickers.sort_custom(_sort_by_rank_desc)
	
	var result_cards = pair_cards.slice(0, 2)
	for i in range(mini(3, kickers.size())):
		result_cards.append(kickers[i])
	
	return {
		"found": true,
		"type": HandType.ONE_PAIR,
		"cards": result_cards
	}

static func _high_card(cards: Array[Card]) -> Dictionary:
	var sorted = cards.duplicate()
	sorted.sort_custom(_sort_by_rank_desc)
	
	return {
		"found": true,
		"type": HandType.HIGH_CARD,
		"cards": sorted.slice(0, 5)
	}

static func _count_ranks(cards: Array[Card]) -> Dictionary:
	var counts: Dictionary = {}
	for card in cards:
		if not counts.has(card.rank):
			counts[card.rank] = 0
		counts[card.rank] += 1
	return counts

static func _get_unique_by_rank(cards: Array[Card]) -> Array[Card]:
	var unique: Array[Card] = []
	var seen_ranks: Array[int] = []
	
	var sorted = cards.duplicate()
	sorted.sort_custom(_sort_by_rank_desc)
	
	for card in sorted:
		if not seen_ranks.has(card.rank):
			unique.append(card)
			seen_ranks.append(card.rank)
	
	return unique

static func _is_consecutive(cards: Array[Card]) -> bool:
	for i in range(cards.size() - 1):
		if cards[i].rank - cards[i + 1].rank != 1:
			return false
	return true

static func _sort_by_rank_desc(a: Card, b: Card) -> bool:
	return a.rank > b.rank

static func _calculate_chips(cards: Array[Card], result: Dictionary) -> int:
	var hand_cards = result["cards"]
	var chips = 0
	
	for card in hand_cards:
		chips += card.get_base_value()
	
	return chips

static func get_hand_type_name(hand_type: HandType) -> String:
	return HAND_NAMES.get(hand_type, "Unknown")

static func get_base_score(hand_type: HandType) -> int:
	return BASE_SCORES.get(hand_type, 0)

static func compare_hands(hand1: Dictionary, hand2: Dictionary) -> int:
	if hand1["type"] != hand2["type"]:
		return hand1["type"] - hand2["type"]
	
	var cards1 = hand1["cards"]
	var cards2 = hand2["cards"]
	
	for i in range(mini(cards1.size(), cards2.size())):
		if cards1[i].rank != cards2[i].rank:
			return cards1[i].rank - cards2[i].rank
	
	return 0
