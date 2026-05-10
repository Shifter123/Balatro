extends TestSuite

var progress_manager: ProgressManager

func setup_progress_manager():
	progress_manager = ProgressManager.new()
	add_child(progress_manager)

func teardown_progress_manager():
	if progress_manager:
		progress_manager.queue_free()
		progress_manager = null

func test_progress_manager_initialization():
	setup_progress_manager()
	
	assert_true(progress_manager.save_system != null, "SaveSystem should be initialized")
	assert_true(progress_manager.stats_tracker != null, "StatsTracker should be initialized")
	assert_true(progress_manager.unlock_system != null, "UnlockSystem should be initialized")
	assert_true(progress_manager.achievement_system != null, "AchievementSystem should be initialized")
	
	teardown_progress_manager()

func test_record_hand_played():
	setup_progress_manager()
	
	var hand_result = {
		"type": HandEvaluator.HandType.FULL_HOUSE,
		"score": 200,
		"cards": [null, null, null, null, null]
	}
	
	progress_manager.record_hand_played(hand_result)
	
	var stats = progress_manager.stats_tracker.get_stats()
	assert_eq(stats["total_hands_played"], 1, "Should have recorded 1 hand")
	assert_eq(stats["full_houses"], 1, "Should have recorded 1 full house")
	
	teardown_progress_manager()

func test_record_game_end():
	setup_progress_manager()
	
	progress_manager.record_game_end(true, 5000, 4)
	
	var stats = progress_manager.stats_tracker.get_stats()
	assert_eq(stats["games_won"], 1, "Should have recorded 1 win")
	assert_eq(stats["highest_score"], 5000, "Should record highest score")
	
	teardown_progress_manager()

func test_achievement_tracking():
	setup_progress_manager()
	
	var initial_unlocked = progress_manager.achievement_system.get_unlocked_count()
	assert_eq(initial_unlocked, 0, "Should start with 0 achievements")
	
	var hand_result = {
		"type": HandEvaluator.HandType.ROYAL_FLUSH,
		"score": 500,
		"cards": []
	}
	
	progress_manager.record_hand_played(hand_result)
	
	var after_hand_unlocked = progress_manager.achievement_system.get_unlocked_count()
	assert_true(after_hand_unlocked > initial_unlocked, "Should unlock achievement after royal flush")
	
	teardown_progress_manager()

func test_stats_summary():
	setup_progress_manager()
	
	progress_manager.record_game_end(true, 3000, 3)
	
	var summary = progress_manager.get_stats_summary()
	assert_true(summary.has("games_played"), "Summary should have games_played")
	assert_true(summary.has("win_rate"), "Summary should have win_rate")
	assert_true(summary.has("highest_score"), "Summary should have highest_score")
	
	teardown_progress_manager()

func test_unlock_summary():
	setup_progress_manager()
	
	var summary = progress_manager.get_unlock_summary()
	assert_true(summary.has("jokers"), "Summary should have jokers info")
	assert_true(summary.has("items"), "Summary should have items info")
	
	teardown_progress_manager()
