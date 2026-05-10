class_name GameManager
extends Node

signal game_initialized
signal game_started
signal round_started(round_info: Dictionary)
signal round_completed(round_result: Dictionary)
signal game_over(final_score: int)
signal state_changed(new_state: GameState)

enum GameState {
	INIT,
	MAIN_MENU,
	PLAYING,
	PAUSED,
	GAME_OVER
}

var current_state: GameState = GameState.INIT

var battle_manager: BattleManager
var random_system: RandomSystem
var game_seed: int = 0

var _current_round: int = 0
var _rounds_to_win: int = 4

func _init() -> void:
	battle_manager = BattleManager.new()
	random_system = RandomSystem.new()
	add_child(battle_manager)
	add_child(random_system)

func _ready() -> void:
	_set_state(GameState.MAIN_MENU)
	game_initialized.emit()

func _set_state(new_state: GameState) -> void:
	current_state = new_state
	state_changed.emit(new_state)

func start_new_game(seed_value: int = 0) -> void:
	if seed_value == 0:
		seed_value = Time.get_ticks_usec()
	
	game_seed = seed_value
	
	random_system.set_seed(game_seed)
	battle_manager.set_seed(game_seed)
	
	battle_manager.start_game()
	_current_round = 0
	
	_set_state(GameState.PLAYING)
	game_started.emit()
	
	start_next_round()

func start_next_round() -> void:
	_current_round += 1
	
	battle_manager.start_round()
	
	var round_info = {
		"round": _current_round,
		"total_rounds": _rounds_to_win,
		"blind_score": battle_manager.blind_score,
		"player_chips": battle_manager.player_chips,
		"player_mult": battle_manager.player_mult
	}
	
	round_started.emit(round_info)

func play_current_hand() -> Dictionary:
	var result = battle_manager.play_hand()
	round_completed.emit(result)
	return result

func evaluate_hand() -> Dictionary:
	return battle_manager.evaluate_current_hand()

func draw_cards(count: int) -> Array[Card]:
	var drawn = battle_manager.card_manager.draw_cards(count)
	return drawn

func discard_hand() -> void:
	battle_manager.card_manager.discard_hand()

func next_round() -> bool:
	if battle_manager.check_game_over():
		end_game()
		return false
	
	if _current_round >= _rounds_to_win:
		end_game()
		return false
	
	start_next_round()
	return true

func end_game() -> void:
	_set_state(GameState.GAME_OVER)
	game_over.emit(battle_manager.player_score)

func return_to_menu() -> void:
	_set_state(GameState.MAIN_MENU)

func get_game_state() -> Dictionary:
	return {
		"state": GameState.keys()[current_state],
		"game_seed": game_seed,
		"current_round": _current_round,
		"total_rounds": _rounds_to_win,
		"battle_state": battle_manager.get_game_state()
	}

func get_hand() -> Array[Card]:
	return battle_manager.card_manager.hand.get_cards()

func get_deck_info() -> Dictionary:
	return battle_manager.card_manager.get_deck_info()
