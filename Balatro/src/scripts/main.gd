extends Node

var game_manager: GameManager

var ui_control: Control
var round_label: Label
var score_label: Label
var chips_label: Label
var blind_label: Label
var hand_label: Label
var hand_score_label: Label
var play_button: Button
var draw_button: Button
var discard_button: Button
var new_game_button: Button

func _ready() -> void:
	game_manager = GameManager.new()
	add_child(game_manager)
	
	_setup_ui()
	_connect_signals()
	
	_update_ui()

func _setup_ui() -> void:
	ui_control = get_node_or_null("UI/Control")
	if ui_control:
		round_label = ui_control.get_node_or_null("ScorePanel/MarginContainer/HBoxContainer/RoundLabel")
		score_label = ui_control.get_node_or_null("ScorePanel/MarginContainer/HBoxContainer/ScoreLabel")
		chips_label = ui_control.get_node_or_null("ScorePanel/MarginContainer/HBoxContainer/ChipsLabel")
		blind_label = ui_control.get_node_or_null("ScorePanel/MarginContainer/HBoxContainer/BlindLabel")
		hand_label = ui_control.get_node_or_null("HandInfoPanel/MarginContainer/HandLabel")
		hand_score_label = ui_control.get_node_or_null("HandInfoPanel/MarginContainer/HandScoreLabel")
		
		var button_container = ui_control.get_node_or_null("ButtonContainer")
		if button_container:
			play_button = button_container.get_node_or_null("PlayButton")
			draw_button = button_container.get_node_or_null("DrawButton")
			discard_button = button_container.get_node_or_null("DiscardButton")
			new_game_button = button_container.get_node_or_null("NewGameButton")
	
	if play_button:
		play_button.pressed.connect(_on_play_button_pressed)
	if draw_button:
		draw_button.pressed.connect(_on_draw_button_pressed)
	if discard_button:
		discard_button.pressed.connect(_on_discard_button_pressed)
	if new_game_button:
		new_game_button.pressed.connect(_on_new_game_button_pressed)

func _connect_signals() -> void:
	game_manager.game_started.connect(_on_game_started)
	game_manager.round_started.connect(_on_round_started)
	game_manager.round_completed.connect(_on_round_completed)
	game_manager.game_over.connect(_on_game_over)

func _update_ui() -> void:
	var state = game_manager.get_game_state()
	var battle_state = state.get("battle_state", {})
	
	if round_label:
		round_label.text = "Round: %d/%d" % [state.get("current_round", 0), state.get("total_rounds", 4)]
	if score_label:
		score_label.text = "Score: %d" % battle_state.get("player_score", 0)
	if chips_label:
		chips_label.text = "Chips: %d" % battle_state.get("player_chips", 100)
	if blind_label:
		blind_label.text = "Blind: %d" % battle_state.get("blind_score", 300)
	
	var hand = game_manager.get_hand()
	if hand_label:
		if hand.size() > 0:
			var card_names: Array = []
			for card in hand:
				card_names.append(card.get_short_name())
			hand_label.text = "Hand: %s" % ", ".join(card_names)
		else:
			hand_label.text = "Hand: Empty"
	
	var eval_result = game_manager.evaluate_hand()
	if hand_score_label:
		hand_score_label.text = "Score: %d (x%d)" % [eval_result.get("score", 0), eval_result.get("mult", 1)]

func _on_play_button_pressed() -> void:
	if game_manager.current_state != GameManager.GameState.PLAYING:
		return
	
	var result = game_manager.play_current_hand()
	print("Hand played: ", result.get("hand_result", {}).get("hand_name", "Unknown"))
	
	if result.get("success", false):
		print("Success! Score: ", result.get("score_earned", 0))
	else:
		print("Failed! Damage: ", result.get("damage_taken", 0))
	
	_update_ui()

func _on_draw_button_pressed() -> void:
	if game_manager.current_state != GameManager.GameState.PLAYING:
		return
	
	game_manager.draw_cards(1)
	_update_ui()

func _on_discard_button_pressed() -> void:
	if game_manager.current_state != GameManager.GameState.PLAYING:
		return
	
	game_manager.discard_hand()
	_update_ui()

func _on_new_game_button_pressed() -> void:
	game_manager.start_new_game()

func _on_game_started() -> void:
	print("Game started!")
	_update_ui()

func _on_round_started(round_info: Dictionary) -> void:
	print("Round started: ", round_info)
	_update_ui()

func _on_round_completed(round_result: Dictionary) -> void:
	print("Round completed: ", round_result)
	_update_ui()

func _on_game_over(final_score: int) -> void:
	print("Game Over! Final Score: ", final_score)
	if hand_label:
		hand_label.text = "GAME OVER!"
	if hand_score_label:
		hand_score_label.text = "Final Score: %d" % final_score
