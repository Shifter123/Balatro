extends Node

func _ready() -> void:
	print("=== 任务3.7：验证点确认 ===")
	print("")

	var all_passed = true

	print("1. 验证游戏包含至少50张可使用卡牌")
	var card_count = verify_card_system()
	print("")

	print("2. 验证游戏包含至少20种小丑牌")
	var joker_count = verify_joker_system()
	print("")

	print("3. 验证游戏包含至少15种道具")
	var item_count = verify_item_system()
	print("")

	print("4. 验证核心系统稳定性")
	var system_stable = verify_system_stability()
	print("")

	print("=== 验证结果汇总 ===")
	if card_count >= 52 and joker_count >= 20 and item_count >= 15 and system_stable:
		print("✓ 所有验证通过！")
		print("  - 卡牌数量: ", card_count)
		print("  - 小丑牌数量: ", joker_count)
		print("  - 道具数量: ", item_count)
	else:
		print("✗ 部分验证失败")
		if card_count < 52:
			print("  - 卡牌数量不足: ", card_count, "/52")
		if joker_count < 20:
			print("  - 小丑牌数量不足: ", joker_count, "/20")
		if item_count < 15:
			print("  - 道具数量不足: ", item_count, "/15")
		if not system_stable:
			print("  - 系统稳定性测试失败")

	print("")
	get_tree().quit()

func verify_card_system() -> int:
	print("  创建标准扑克牌组...")
	var deck = Deck.new()
	add_child(deck)
	deck.create_standard_deck()

	var count = deck.cards.size()
	if count == 52:
		print("  ✓ 包含52张标准扑克牌")
	else:
		print("  ✗ 卡牌数量异常: ", count)

	deck.queue_free()
	return count

func verify_joker_system() -> int:
	print("  加载小丑牌模板...")
	var joker_manager = JokerManager.new()
	add_child(joker_manager)

	var templates_loaded = joker_manager._joker_templates.size()
	print("  已加载小丑牌模板: ", templates_loaded)

	var test_jokers = [
		"joker_1", "joker_2", "joker_3", "joker_4", "joker_5",
		"joker_6", "joker_7", "joker_8", "joker_9", "joker_10",
		"joker_11", "joker_12", "joker_13", "joker_14", "joker_15",
		"joker_16", "joker_17", "joker_18", "joker_19", "joker_20"
	]

	var created_count = 0
	for joker_id in test_jokers:
		var joker = joker_manager.create_joker(joker_id)
		if joker != null:
			created_count += 1

	if created_count >= 20:
		print("  ✓ 包含至少20种小丑牌")
	else:
		print("  ✗ 小丑牌数量不足: ", created_count)

	joker_manager.queue_free()
	return created_count

func verify_item_system() -> int:
	print("  加载道具模板...")
	var item_manager = ConsumableManager.new()
	add_child(item_manager)

	var tarot_count = item_manager._tarot_templates.size()
	var planet_count = item_manager._planet_templates.size()
	var voucher_count = item_manager._voucher_templates.size()

	print("  塔罗牌: ", tarot_count)
	print("  星球卡: ", planet_count)
	print("  代金券: ", voucher_count)

	var total_items = tarot_count + planet_count + voucher_count
	if total_items >= 15:
		print("  ✓ 包含至少15种道具")
	else:
		print("  ✗ 道具数量不足: ", total_items)

	item_manager.queue_free()
	return total_items

func verify_system_stability() -> bool:
	print("  测试核心系统稳定性...")

	var test_count = 10
	var success_count = 0

	for i in range(test_count):
		var game_manager = GameManager.new()
		add_child(game_manager)

		game_manager.start_new_game(i * 1000)

		for round_num in range(4):
			var hand = game_manager.get_hand()
			var result = game_manager.evaluate_hand()
			game_manager.play_current_hand()

			if round_num < 3:
				game_manager.next_round()

		var final_state = game_manager.get_game_state()
		if final_state["current_round"] > 0:
			success_count += 1

		game_manager.queue_free()

	print("  完成测试: ", success_count, "/", test_count)

	if success_count == test_count:
		print("  ✓ 所有核心系统运行稳定")
		return true
	else:
		print("  ✗ 系统稳定性测试失败")
		return false
