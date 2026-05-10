extends CanvasLayer

signal hud_updated

@onready var round_label: Label = $TopBar/RoundPanel/MarginContainer/RoundLabel
@onready var score_label: Label = $TopBar/ScorePanel/MarginContainer/ScoreLabel
@onready var chips_label: Label = $TopBar/ChipsPanel/MarginContainer/ChipsLabel
@onready var blind_label: Label = $TopBar/BlindPanel/MarginContainer/BlindLabel
@onready var hand_label: Label = $BottomBar/HandLabel
@onready var score_preview: Label = $BottomBar/ScorePreview

func _ready() -> void:
	_update_ui()

func update_round(round_num: int, total_rounds: int) -> void:
	round_label.text = "Round %d/%d" % [round_num, total_rounds]
	emit_signal("hud_updated")

func update_score(score: int) -> void:
	score_label.text = "Score: %d" % score
	emit_signal("hud_updated")

func update_chips(chips: int) -> void:
	chips_label.text = "Chips: %d" % chips
	emit_signal("hud_updated")

func update_blind(blind_score: int) -> void:
	blind_label.text = "Blind: %d" % blind_score
	emit_signal("hud_updated")

func update_hand(hand_text: String) -> void:
	hand_label.text = "Hand: %s" % hand_text
	emit_signal("hud_updated")

func update_score_preview(score: int, mult: int = 1) -> void:
	score_preview.text = "Score: %d (x%d)" % [score, mult]
	emit_signal("hud_updated")

func update_from_game_state(state: Dictionary) -> void:
	var battle_state = state.get("battle_state", {})
	update_round(state.get("current_round", 1), state.get("total_rounds", 4))
	update_score(battle_state.get("player_score", 0))
	update_chips(battle_state.get("player_chips", 100))
	update_blind(battle_state.get("blind_score", 300))

func _update_ui() -> void:
	pass
