extends Control

signal shop_closed
signal item_purchased(item_id: String, cost: int)
signal joker_purchased(joker_id: String, cost: int)
signal voucher_purchased(voucher_id: String, cost: int)
signal shop_skipped

@onready var ante_label: Label = $TopBar/AnteLabel
@onready var money_label: Label = $TopBar/MoneyLabel
@onready var skip_button: Button = $SkipButton
@onready var joker_slots: VBoxContainer = $ShopContainer/JokerSection/JokerSlots
@onready var item_slots: VBoxContainer = $ShopContainer/ItemSection/ItemSlots
@onready var voucher_slots: VBoxContainer = $ShopContainer/VoucherSection/VoucherSlots
@onready var joker_slots_label: Label = $BottomBar/JokerSlotsLabel

var money: int = 4
var ante: int = 1
var joker_manager: JokerManager

func _ready() -> void:
	joker_manager = JokerManager.new()
	add_child(joker_manager)
	
	skip_button.pressed.connect(_on_skip_pressed)
	_update_ui()

func setup(p_ante: int, p_money: int) -> void:
	ante = p_ante
	money = p_money
	_update_ui()

func _update_ui() -> void:
	ante_label.text = "Ante %d" % ante
	money_label.text = "$%d" % money
	
	var used = joker_manager.get_used_slots()
	var total = joker_manager.available_slots
	joker_slots_label.text = "Joker Slots: %d/%d" % [used, total]

func _on_skip_pressed() -> void:
	shop_skipped.emit()
	shop_closed.emit()
	queue_free()

func add_joker_to_shop(joker_id: String, cost: int) -> void:
	var panel = _create_shop_item(joker_id, cost, "joker")
	joker_slots.add_child(panel)

func add_item_to_shop(item_id: String, cost: int) -> void:
	var panel = _create_shop_item(item_id, cost, "item")
	item_slots.add_child(panel)

func add_voucher_to_shop(voucher_id: String, cost: int) -> void:
	var panel = _create_shop_item(voucher_id, cost, "voucher")
	voucher_slots.add_child(panel)

func _create_shop_item(id: String, cost: int, item_type: String) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(150, 100)
	
	var label = Label.new()
	label.text = "%s\n$%d" % [id, cost]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	panel.add_child(label)
	
	return panel

func can_afford(cost: int) -> bool:
	return money >= cost

func spend_money(amount: int) -> bool:
	if not can_afford(amount):
		return false
	money -= amount
	_update_ui()
	return true
