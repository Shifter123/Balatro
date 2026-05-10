extends Node

var game_manager: GameManager

func _ready() -> void:
	print("=== Balatro Core Loop Test ===")
	print("")
	
	game_manager = GameManager.new()
	add_child(game_manager)
	
	test_full_game_loop()
	
	print("")
	print("=== All tests passed! ===")
	
	get_tree().quit()

func test_full_game_loop() -> void:
	print("Test 1: Full Game Loop")
	print("------------------------")
	
	game_manager.start_new_game(12345)
	print("Game started with seed: 12345")
	
	var state = game_manager.get_game_state()
	print("Initial state: ", state)
	print("")
	
	for round_num in range(1, 5):
		print("=== Round ", round_num, " ===")
		
		var hand = game_manager.get_hand()
		print("Cards in hand: ", hand.size())
		
		for card in hand:
			print("  ", card.get_display_name(), " (", card.get_short_name(), ")")
		
		var eval_result = game_manager.evaluate_hand()
		print("Hand evaluation: ", eval_result["hand_name"])
		print("  Score: ", eval_result["score"], " (Chips: ", eval_result["chips"], " x Mult: ", eval_result["mult"], ")")
		print("  Blind score: ", eval_result["blind_score"])
		
		var play_result = game_manager.play_current_hand()
		if play_result["success"]:
			print("✓ Won! Earned: ", play_result["score_earned"])
		else:
			print("✗ Lost! Damage: ", play_result["damage_taken"])
		
		var new_state = game_manager.get_game_state()
		print("Chips: ", new_state["battle_state"]["player_chips"])
		print("Score: ", new_state["battle_state"]["player_score"])
		print("")
		
		if round_num < 4:
			game_manager.next_round()
	
	print("=== Game Complete ===")
	print("Final Score: ", game_manager.get_game_state()["battle_state"]["player_score"])
	print("")
	
	game_manager.queue_free()
	game_manager = GameManager.new()
	add_child(game_manager)

func test_deterministic_replay() -> void:
	print("Test 2: Deterministic Replay")
	print("---------------------------")
	
	var seed = 54321
	
	game_manager.start_new_game(seed)
	var hand1 = game_manager.get_hand()
	var eval1 = game_manager.evaluate_hand()
	game_manager.play_current_hand()
	
	print("First run - Hand: ", eval1["hand_name"], ", Score: ", eval1["score"])
	
	game_manager.queue_free()
	game_manager = GameManager.new()
	add_child(game_manager)
	
	game_manager.start_new_game(seed)
	var hand2 = game_manager.get_hand()
	var eval2 = game_manager.evaluate_hand()
	game_manager.play_current_hand()
	
	print("Second run - Hand: ", eval2["hand_name"], ", Score: ", eval2["score"])
	
	if eval1["type"] == eval2["type"]:
		print("✓ Deterministic: Same hand type!")
	else:
		print("✗ Error: Different hand types!")
	
	print("")

func test_hand_types() -> void:
	print("Test 3: Hand Type Recognition")
	print("-----------------------------")
	
	var test_cases = [
		{
			"name": "Royal Flush",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.ACE),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.KING),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.JACK),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TEN)
			]
		},
		{
			"name": "Straight Flush",
			"cards": [
				Card.new(Globals.Suit.SPADES, Globals.CardRank.NINE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.EIGHT),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.SIX),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.FIVE)
			]
		},
		{
			"name": "Four of a Kind",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.KING),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.KING),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.KING),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.KING),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.THREE)
			]
		},
		{
			"name": "Full House",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.FIVE),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.FIVE)
			]
		},
		{
			"name": "Flush",
			"cards": [
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.KING),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.EIGHT),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SIX),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.TWO)
			]
		},
		{
			"name": "Straight",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.NINE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.EIGHT),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.SIX),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.FIVE)
			]
		},
		{
			"name": "Three of a Kind",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.JACK),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TWO)
			]
		},
		{
			"name": "Two Pair",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.TEN),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.KING)
			]
		},
		{
			"name": "One Pair",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.ACE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.ACE),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.NINE),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.SIX),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.THREE)
			]
		},
		{
			"name": "High Card",
			"cards": [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.ACE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.JACK),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TWO)
			]
		}
	]
	
	for test_case in test_cases:
		var result = HandEvaluator.evaluate_hand(test_case["cards"])
		var status = "✓" if result["hand_name"] == test_case["name"] else "✗"
		print(status, " ", test_case["name"], ": ", result["hand_name"], " (Score: ", result["score"], ")")
	
	print("")
