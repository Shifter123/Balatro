extends TestSuite

var steam_integration: SteamIntegration
var platform_manager: PlatformManager

func test_steam_integration_creation():
	steam_integration = SteamIntegration.new()
	add_child(steam_integration)
	
	assert_true(steam_integration != null, "SteamIntegration should be created")
	assert_false(steam_integration.is_steam_enabled, "Should start disabled")
	
	steam_integration.queue_free()

func test_platform_manager_creation():
	platform_manager = PlatformManager.new()
	add_child(platform_manager)
	
	assert_true(platform_manager != null, "PlatformManager should be created")
	assert_true(platform_manager.current_platform != null, "Should have platform detected")
	
	platform_manager.queue_free()

func test_platform_detection():
	platform_manager = PlatformManager.new()
	add_child(platform_manager)
	
	var info = platform_manager.get_platform_info()
	assert_true(info.has("platform"), "Should have platform info")
	assert_true(info.has("cloud_save"), "Should have cloud_save info")
	assert_true(info.has("achievements"), "Should have achievements info")
	
	platform_manager.queue_free()

func test_achievement_ids_mapping():
	steam_integration = SteamIntegration.new()
	add_child(steam_integration)
	
	var achievement_ids = SteamIntegration.ACHIEVEMENT_IDS
	assert_true(achievement_ids.has("first_win"), "Should have first_win achievement")
	assert_true(achievement_ids.has("play_royal_flush"), "Should have royal_flush achievement")
	assert_true(achievement_ids.size() >= 15, "Should have at least 15 achievements")
	
	steam_integration.queue_free()

func test_leaderboard_ids_mapping():
	steam_integration = SteamIntegration.new()
	add_child(steam_integration)
	
	var leaderboard_ids = SteamIntegration.LEADERBOARD_IDS
	assert_true(leaderboard_ids.has("high_score"), "Should have high_score leaderboard")
	assert_true(leaderboard_ids.has("total_wins"), "Should have total_wins leaderboard")
	
	steam_integration.queue_free()

func test_platform_info_structure():
	platform_manager = PlatformManager.new()
	add_child(platform_manager)
	
	var info = platform_manager.get_platform_info()
	assert_eq(info["platform"], platform_manager.platform_name, "Platform name should match")
	assert_eq(typeof(info["cloud_save"]), TYPE_BOOL, "cloud_save should be boolean")
	assert_eq(typeof(info["achievements"]), TYPE_BOOL, "achievements should be boolean")
	
	platform_manager.queue_free()

func test_steam_achievement_unlock_offline():
	steam_integration = SteamIntegration.new()
	add_child(steam_integration)
	
	var result = steam_integration.unlock_achievement("first_win")
	assert_false(result, "Should return false when Steam not enabled")
	
	steam_integration.queue_free()

func test_platform_achievement_unlock_offline():
	platform_manager = PlatformManager.new()
	add_child(platform_manager)
	
	platform_manager.initialize()
	
	var result = platform_manager.unlock_achievement("first_win")
	assert_false(result, "Should return false when achievements not available in standalone")
	
	platform_manager.queue_free()
