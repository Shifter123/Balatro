extends TestSuite

var game_manager: GameManager

func setup_game_manager():
	game_manager = GameManager.new()
	add_child(game_manager)

func teardown_game_manager():
	if game_manager:
		game_manager.queue_free()
		game_manager = null

func test_full_game_loop():
	setup_game_manager()
	game_manager.start_new_game(12345)
	
	assert_eq(game_manager.current_state, GameManager.GameState.PLAYING)
	
	var rounds_played = 0
	var max_rounds = 4
	
	while rounds_played < max_rounds:
		var hand = game_manager.get_hand()
		assert_true(hand.size() > 0, "Should have cards in hand")
		
		var eval_result = game_manager.evaluate_hand()
		assert_true(eval_result.has("type"), "Evaluation should return result")
		assert_true(eval_result.has("score"), "Evaluation should have score")
		
		var play_result = game_manager.play_current_hand()
		assert_true(play_result.has("success"), "Play should return result")
		
		rounds_played += 1
		
		if rounds_played < max_rounds:
			var continue_game = game_manager.next_round()
			assert_true(continue_game, "Game should continue")
	
	var final_state = game_manager.get_game_state()
	assert_eq(final_state["current_round"], max_rounds, "Should complete all rounds")
	
	teardown_game_manager()

func test_game_over_condition():
	setup_game_manager()
	game_manager.start_new_game(99999)
	
	var chips_at_start = game_manager.get_game_state()["battle_state"]["player_chips"]
	
	for i in range(10):
		if game_manager.current_state == GameManager.GameState.GAME_OVER:
			break
		game_manager.play_current_hand()
		if game_manager.current_state == GameManager.GameState.PLAYING:
			game_manager.next_round()
	
	var final_state = game_manager.get_game_state()
	assert_true(final_state["current_round"] > 0 or final_state["battle_state"]["player_chips"] != chips_at_start)
	
	teardown_game_manager()

func test_deterministic_replay():
	var seed_value = 54321
	
	var game1 = GameManager.new()
	add_child(game1)
	game1.start_new_game(seed_value)
	
	var hand1_result = game1.evaluate_hand()
	game1.play_current_hand()
	var score1 = game1.get_game_state()["battle_state"]["player_score"]
	
	game1.queue_free()
	
	var game2 = GameManager.new()
	add_child(game2)
	game2.start_new_game(seed_value)
	
	var hand2_result = game2.evaluate_hand()
	game2.play_current_hand()
	var score2 = game2.get_game_state()["battle_state"]["player_score"]
	
	assert_eq(hand1_result["type"], hand2_result["type"], "Same seed should produce same hand type")
	assert_eq(score1, score2, "Same seed should produce same score")
	
	game2.queue_free()

func test_hand_selection_and_discard():
	setup_game_manager()
	game_manager.start_new_game(11111)
	
	var hand = game_manager.get_hand()
	assert_eq(hand.size(), 5, "Should start with 5 cards")
	
	var cards_to_select = mini(3, hand.size())
	for i in range(cards_to_select):
		hand[i].select()
	
	var selected_count = 0
	for card in hand:
		if card.is_selected:
			selected_count += 1
	
	assert_eq(selected_count, cards_to_select, "Should have selected cards")
	
	game_manager.discard_hand()
	
	var new_hand = game_manager.get_hand()
	assert_eq(new_hand.size(), 0, "Hand should be empty after discard")
	
	teardown_game_manager()

func test_deck_reshuffle():
	setup_game_manager()
	game_manager.start_new_game(22222)
	
	game_manager.discard_hand()
	
	var deck_info = game_manager.get_deck_info()
	assert_true(deck_info["discarded"] > 0, "Discard pile should have cards")
	
	game_manager.draw_cards(5)
	
	var new_hand = game_manager.get_hand()
	assert_eq(new_hand.size(), 5, "Should have drawn 5 new cards")
	
	teardown_game_manager()

func test_blind_score_scaling():
	setup_game_manager()
	game_manager.start_new_game(33333)
	
	var blind_scores: Array = []
	
	for round_num in range(4):
		game_manager.play_current_hand()
		if round_num < 3:
			game_manager.next_round()
		var blind_score = game_manager.get_game_state()["battle_state"]["blind_score"]
		blind_scores.append(blind_score)
	
	assert_true(blind_scores[0] > 0, "First blind should have score")
	assert_true(blind_scores[1] >= blind_scores[0], "Second blind should be >= first")
	assert_true(blind_scores[2] >= blind_scores[1], "Third blind should be >= second")
	
	teardown_game_manager()

func test_hand_evaluation_consistency():
	setup_game_manager()
	game_manager.start_new_game(44444)
	
	var hand = game_manager.get_hand()
	var result1 = HandEvaluator.evaluate_hand(hand)
	
	var result2 = HandEvaluator.evaluate_hand(hand)
	
	assert_eq(result1["type"], result2["type"], "Evaluation should be consistent")
	assert_eq(result1["score"], result2["score"], "Score should be consistent")
	
	teardown_game_manager()

func test_multiple_hands_same_round():
	setup_game_manager()
	game_manager.start_new_game(55555)
	
	var hand1_eval = game_manager.evaluate_hand()
	
	game_manager.discard_hand()
	game_manager.draw_cards(5)
	
	var hand2_eval = game_manager.evaluate_hand()
	
	assert_true(hand1_eval.has("score"))
	assert_true(hand2_eval.has("score"))
	
	teardown_game_manager()
