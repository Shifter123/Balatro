extends Control

signal card_clicked(card: Card)
signal card_selected(card: Card)
signal card_deselected(card: Card)

@onready var rank_label: Label = $Panel/MarginContainer/VBoxContainer/RankLabel
@onready var suit_label: Label = $Panel/MarginContainer/VBoxContainer/SuitLabel
@onready var rank_label2: Label = $Panel/MarginContainer/VBoxContainer/RankLabel2
@onready var panel: PanelContainer = $Panel

var card: Card = null
var is_selected_state: bool = false

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func set_card(p_card: Card) -> void:
	card = p_card
	_update_display()

func _update_display() -> void:
	if card == null:
		rank_label.text = ""
		suit_label.text = ""
		rank_label2.text = ""
		return
	
	rank_label.text = Globals.RANK_NAMES[card.rank]
	suit_label.text = Globals.SUIT_SYMBOLS[card.suit]
	rank_label2.text = Globals.RANK_NAMES[card.rank]
	
	var color = card.get_suit_color()
	rank_label.add_theme_color_override("font_color", color)
	suit_label.add_theme_color_override("font_color", color)
	rank_label2.add_theme_color_override("font_color", color)
	
	if card.is_face_up:
		panel.self_modulate = Color.WHITE
	else:
		panel.self_modulate = Color.GRAY

func set_selected(selected: bool) -> void:
	is_selected_state = selected
	if selected:
		panel.border_color = Color.YELLOW
		panel.border_width_left = 3
		panel.border_width_top = 3
		panel.border_width_right = 3
		panel.border_width_bottom = 3
	else:
		panel.border_color = Color.TRANSPARENT
		panel.border_width_left = 0
		panel.border_width_top = 0
		panel.border_width_right = 0
		panel.border_width_bottom = 0

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			card_clicked.emit(card)
			if card != null:
				card.toggle_selection()
				if card.is_selected:
					card_selected.emit(card)
					set_selected(true)
				else:
					card_deselected.emit(card)
					set_selected(false)

func get_card() -> Card:
	return card
