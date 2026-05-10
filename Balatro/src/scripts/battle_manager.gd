class_name BattleManager
extends Node

signal round_started(round_number: int)
signal round_ended(round_result: Dictionary)
signal game_started
signal game_ended(final_score: int)

var card_manager: CardManager
var hand_evaluator: Node

var current_round: int = 0
var max_rounds: int = 4
var ante_level: int = 1

var player_score: int = 0
var player_chips: int = 100
var player_mult: int = 1

var blind_score: int = 300
var current_hand_result: Dictionary = {}
var last_round_result: Dictionary = {}

var rng: RandomNumberGenerator

func _init() -> void:
	card_manager = CardManager.new()
	add_child(card_manager)
	hand_evaluator = Node.new()
	add_child(hand_evaluator)
	rng = RandomNumberGenerator.new()
	rng.randomize()

func start_game() -> void:
	player_score = 0
	player_chips = 100
	player_mult = 1
	current_round = 0
	game_started.emit()

func start_round() -> void:
	current_round += 1
	card_manager.setup_new_round()
	card_manager.deal_initial_hand()
	blind_score = _calculate_blind_score()
	round_started.emit(current_round)

func _calculate_blind_score() -> int:
	var base_score = 200 + (ante_level - 1) * 100
	var round_multiplier = [1, 2, 4][mini(current_round - 1, 2)]
	return base_score * round_multiplier

func evaluate_current_hand() -> Dictionary:
	var hand = card_manager.hand.get_cards()
	var result = HandEvaluator.evaluate_hand(hand)
	result["blind_score"] = blind_score
	result["player_chips"] = player_chips
	result["player_mult"] = player_mult
	result["is_win"] = result["score"] >= blind_score
	current_hand_result = result
	return result

func play_hand() -> Dictionary:
	var result = evaluate_current_hand()
	
	if result["is_win"]:
		var chips_earned = result["chips"]
		var mult_earned = result["mult"]
		
		player_score += chips_earned * mult_earned
		player_chips = player_chips - blind_score + chips_earned
		
		card_manager.discard_hand()
		last_round_result = {
			"success": true,
			"round": current_round,
			"score_earned": chips_earned * mult_earned,
			"hand_result": result
		}
	else:
		player_chips -= blind_score
		
		card_manager.discard_hand()
		last_round_result = {
			"success": false,
			"round": current_round,
			"damage_taken": blind_score,
			"hand_result": result
		}
	
	round_ended.emit(last_round_result)
	return last_round_result

func check_game_over() -> bool:
	return player_chips <= 0

func is_last_round() -> bool:
	return current_round >= max_rounds

func get_game_state() -> Dictionary:
	return {
		"current_round": current_round,
		"max_rounds": max_rounds,
		"ante_level": ante_level,
		"player_score": player_score,
		"player_chips": player_chips,
		"player_mult": player_mult,
		"blind_score": blind_score,
		"is_game_over": check_game_over()
	}

func set_seed(seed_value: int) -> void:
	rng.seed = seed_value
	Globals.set_seed(seed_value)

func reset() -> void:
	card_manager = CardManager.new()
	add_child(card_manager)
	current_round = 0
	player_score = 0
	player_chips = 100
	player_mult = 1
