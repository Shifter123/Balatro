class_name PlatformManager
extends Node

signal platform_initialized
signal platform_changed(new_platform: String)

enum Platform {
	STEAM,
	EPIC,
	GOG,
	MOBILE_IOS,
	MOBILE_ANDROID,
	WEB,
	STANDALONE
}

var current_platform: Platform = Platform.STANDALONE
var platform_name: String = "Standalone"

var steam_integration: SteamIntegration

var _is_initialized: bool = false
var _cloud_save_enabled: bool = false
var _achievements_enabled: bool = false
var _leaderboards_enabled: bool = false
var _analytics_enabled: bool = false

func _init() -> void:
	_detect_platform()

func _detect_platform() -> void:
	if OS.has_feature("steam"):
		current_platform = Platform.STEAM
		platform_name = "Steam"
	elif OS.has_feature("ios"):
		current_platform = Platform.MOBILE_IOS
		platform_name = "iOS"
	elif OS.has_feature("android"):
		current_platform = Platform.MOBILE_ANDROID
		platform_name = "Android"
	elif OS.has_feature("web"):
		current_platform = Platform.WEB
		platform_name = "Web"
	else:
		current_platform = Platform.STANDALONE
		platform_name = "Standalone"

	print("Detected platform: ", platform_name)

func initialize() -> bool:
	if _is_initialized:
		return true

	match current_platform:
		Platform.STEAM:
			_initialize_steam()
		Platform.MOBILE_IOS:
			_initialize_mobile_ios()
		Platform.MOBILE_ANDROID:
			_initialize_mobile_android()
		Platform.WEB:
			_initialize_web()
		_:
			_initialize_standalone()

	_is_initialized = true
	platform_initialized.emit()
	return true

func _initialize_steam() -> void:
	steam_integration = SteamIntegration.new()
	add_child(steam_integration)

	var success = steam_integration.initialize()
	if success:
		_cloud_save_enabled = true
		_achievements_enabled = true
		_leaderboards_enabled = true
		_analytics_enabled = true
		print("Steam platform initialized")
	else:
		print("Steam initialization failed, falling back to standalone")
		current_platform = Platform.STANDALONE
		platform_name = "Standalone"

func _initialize_mobile_ios() -> void:
	_cloud_save_enabled = true
	_achievements_enabled = true
	_leaderboards_enabled = true
	print("iOS platform initialized")

func _initialize_mobile_android() -> void:
	_cloud_save_enabled = true
	_achievements_enabled = true
	_leaderboards_enabled = true
	print("Android platform initialized")

func _initialize_web() -> void:
	_cloud_save_enabled = false
	_achievements_enabled = false
	_leaderboards_enabled = false
	_analytics_enabled = false
	print("Web platform initialized")

func _initialize_standalone() -> void:
	_cloud_save_enabled = false
	_achievements_enabled = false
	_leaderboards_enabled = false
	_analytics_enabled = false
	print("Standalone platform initialized")

func unlock_achievement(achievement_id: String) -> bool:
	if not _achievements_enabled:
		return false

	match current_platform:
		Platform.STEAM:
			if steam_integration:
				return steam_integration.unlock_achievement(achievement_id)
		Platform.MOBILE_IOS, Platform.MOBILE_ANDROID:
			return _unlock_mobile_achievement(achievement_id)

	return false

func _unlock_mobile_achievement(achievement_id: String) -> bool:
	return false

func update_leaderboard(leaderboard_name: String, score: int) -> bool:
	if not _leaderboards_enabled:
		return false

	match current_platform:
		Platform.STEAM:
			if steam_integration:
				return steam_integration.update_leaderboard(leaderboard_name, score)
		Platform.MOBILE_IOS, Platform.MOBILE_ANDROID:
			return _update_mobile_leaderboard(leaderboard_name, score)

	return false

func _update_mobile_leaderboard(leaderboard_name: String, score: int) -> bool:
	return false

func save_to_cloud(file_name: String, data: PackedByteArray) -> bool:
	if not _cloud_save_enabled:
		return false

	match current_platform:
		Platform.STEAM:
			if steam_integration:
				return steam_integration.save_to_cloud(file_name, data)
		Platform.MOBILE_IOS:
			return _save_to_icloud(file_name, data)
		Platform.MOBILE_ANDROID:
			return _save_to_google_play(file_name, data)

	return false

func _save_to_icloud(file_name: String, data: PackedByteArray) -> bool:
	return false

func _save_to_google_play(file_name: String, data: PackedByteArray) -> bool:
	return false

func load_from_cloud(file_name: String) -> PackedByteArray:
	if not _cloud_save_enabled:
		return PackedByteArray()

	match current_platform:
		Platform.STEAM:
			if steam_integration:
				return steam_integration.load_from_cloud(file_name)
		Platform.MOBILE_IOS:
			return _load_from_icloud(file_name)
		Platform.MOBILE_ANDROID:
			return _load_from_google_play(file_name)

	return PackedByteArray()

func _load_from_icloud(file_name: String) -> PackedByteArray:
	return PackedByteArray()

func _load_from_google_play(file_name: String) -> PackedByteArray:
	return PackedByteArray()

func show_achievements_ui() -> void:
	match current_platform:
		Platform.STEAM:
			if steam_integration:
				steam_integration.show_overlay("achievements")
		Platform.MOBILE_IOS, Platform.MOBILE_ANDROID:
			_show_mobile_achievements_ui()

func _show_mobile_achievements_ui() -> void:
	pass

func show_leaderboard_ui(leaderboard_name: String = "") -> void:
	match current_platform:
		Platform.STEAM:
			if steam_integration:
				steam_integration.show_overlay("leaderboard")
		Platform.MOBILE_IOS, Platform.MOBILE_ANDROID:
			_show_mobile_leaderboard_ui(leaderboard_name)

func _show_mobile_leaderboard_ui(leaderboard_name: String) -> void:
	pass

func is_cloud_save_available() -> bool:
	return _cloud_save_enabled

func is_achievements_available() -> bool:
	return _achievements_enabled

func is_leaderboards_available() -> bool:
	return _leaderboards_enabled

func get_platform_info() -> Dictionary:
	return {
		"platform": platform_name,
		"platform_type": current_platform,
		"cloud_save": _cloud_save_enabled,
		"achievements": _achievements_enabled,
		"leaderboards": _leaderboards_enabled,
		"analytics": _analytics_enabled
	}

func set_rich_presence(key: String, value: String) -> void:
	match current_platform:
		Platform.STEAM:
			if steam_integration:
				steam_integration.set_rich_presence(key, value)

func update_game_state_presence(state: String, details: String = "") -> void:
	set_rich_presence("state", state)
	if not details.is_empty():
		set_rich_presence("details", details)

func shutdown() -> void:
	match current_platform:
		Platform.STEAM:
			if steam_integration:
				steam_integration.shutdown()

	_is_initialized = false
	print("Platform manager shut down")
