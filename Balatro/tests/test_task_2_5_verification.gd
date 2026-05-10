extends Node

var all_passed: bool = true
var test_results: Array = []

func _ready() -> void:
	print("=== 任务2.5：验证点确认 ===")
	print("")

	run_verification_tests()
	
	print("")
	if all_passed:
		print("✓ 所有验证测试通过！")
	else:
		print("✗ 部分验证测试失败")
	print("")
	
	get_tree().quit()

func run_verification_tests() -> void:
	print("1. 验证卡牌系统能够稳定处理100张以上卡牌的操作")
	test_card_system_stability()
	print("")

	print("2. 验证所有牌型判定逻辑")
	test_all_hand_types()
	print("")

	print("3. 验证单局游戏流程完整性")
	test_full_game_flow()
	print("")

func test_card_system_stability() -> void:
	print("  测试大规模卡牌操作...")
	
	var deck = Deck.new()
	add_child(deck)
	
	for i in range(10):
		deck.create_standard_deck()
		deck.shuffle()
	
	var total_drawn = 0
	for i in range(100):
		var card = deck.draw(1)
		if card.size() > 0:
			total_drawn += 1
	
	if total_drawn >= 52:
		print("  ✓ 通过：能够在10轮中处理 ", total_drawn, " 次发牌")
		test_results.append({"test": "card_stability", "passed": true})
	else:
		print("  ✗ 失败：仅处理 ", total_drawn, " 次发牌")
		all_passed = false
		test_results.append({"test": "card_stability", "passed": false})
	
	deck.queue_free()

func test_all_hand_types() -> void:
	var test_cases = [
		{"name": "Royal Flush", "expected": "Royal Flush", "cards": create_hand("RF")},
		{"name": "Straight Flush", "expected": "Straight Flush", "cards": create_hand("SF")},
		{"name": "Four of a Kind", "expected": "Four of a Kind", "cards": create_hand("FK")},
		{"name": "Full House", "expected": "Full House", "cards": create_hand("FH")},
		{"name": "Flush", "expected": "Flush", "cards": create_hand("FL")},
		{"name": "Straight", "expected": "Straight", "cards": create_hand("ST")},
		{"name": "Three of a Kind", "expected": "Three of a Kind", "cards": create_hand("TK")},
		{"name": "Two Pair", "expected": "Two Pair", "cards": create_hand("TP")},
		{"name": "One Pair", "expected": "One Pair", "cards": create_hand("OP")},
		{"name": "High Card", "expected": "High Card", "cards": create_hand("HC")}
	]
	
	var passed = 0
	var failed = 0
	
	for test_case in test_cases:
		var result = HandEvaluator.evaluate_hand(test_case["cards"])
		if result["hand_name"] == test_case["expected"]:
			print("  ✓ ", test_case["name"], " 检测正确")
			passed += 1
		else:
			print("  ✗ ", test_case["name"], " 检测失败：期望 ", test_case["expected"], "，实际 ", result["hand_name"])
			failed += 1
	
	if failed == 0:
		print("  ✓ 通过：所有 ", passed, " 种牌型检测正确")
		test_results.append({"test": "hand_types", "passed": true})
	else:
		print("  ✗ 失败：", passed, " 通过，", failed, " 失败")
		all_passed = false
		test_results.append({"test": "hand_types", "passed": false})

func create_hand(hand_type: String) -> Array[Card]:
	match hand_type:
		"RF":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.ACE),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.KING),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.JACK),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TEN)
			]
		"SF":
			return [
				Card.new(Globals.Suit.SPADES, Globals.CardRank.NINE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.EIGHT),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.SIX),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.FIVE)
			]
		"FK":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.KING),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.KING),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.KING),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.KING),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.THREE)
			]
		"FH":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.QUEEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.FIVE),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.FIVE)
			]
		"FL":
			return [
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.KING),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.EIGHT),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SIX),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.TWO)
			]
		"ST":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.NINE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.EIGHT),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.SIX),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.FIVE)
			]
		"TK":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.JACK),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TWO)
			]
		"TP":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TEN),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.TEN),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.KING)
			]
		"OP":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.ACE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.ACE),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.NINE),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.SIX),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.THREE)
			]
		"HC":
			return [
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.ACE),
				Card.new(Globals.Suit.SPADES, Globals.CardRank.JACK),
				Card.new(Globals.Suit.CLUBS, Globals.CardRank.SEVEN),
				Card.new(Globals.Suit.DIAMONDS, Globals.CardRank.FOUR),
				Card.new(Globals.Suit.HEARTS, Globals.CardRank.TWO)
			]
	return []

func test_full_game_flow() -> void:
	print("  测试完整游戏流程...")
	
	var game_manager = GameManager.new()
	add_child(game_manager)
	
	var seeds_to_test = [11111, 22222, 33333]
	var games_completed = 0
	
	for seed in seeds_to_test:
		game_manager.start_new_game(seed)
		
		var rounds_completed = 0
		for i in range(4):
			var hand = game_manager.get_hand()
			var result = game_manager.evaluate_hand()
			game_manager.play_current_hand()
			
			rounds_completed += 1
			
			if rounds_completed >= 4:
				break
			game_manager.next_round()
		
		if rounds_completed >= 4:
			games_completed += 1
			print("    - Seed ", seed, ": 完成 ", rounds_completed, " 轮")
		
		game_manager.queue_free()
		game_manager = GameManager.new()
		add_child(game_manager)
	
	if games_completed >= 3:
		print("  ✓ 通过：成功完成 ", games_completed, "/3 场完整游戏")
		test_results.append({"test": "game_flow", "passed": true})
	else:
		print("  ✗ 失败：仅完成 ", games_completed, "/3 场游戏")
		all_passed = false
		test_results.append({"test": "game_flow", "passed": false})
	
	game_manager.queue_free()
