extends Node

signal animation_started(anim_name: String)
signal animation_finished(anim_name: String)

enum EffectType {
	CARD_FLIP,
	CARD_SHAKE,
	CARD_BREAK,
	SCORE_POPUP,
	CHIPS_POPUP,
	MULT_POPUP,
	WIN_EFFECT,
	LOSE_EFFECT,
	LEVEL_UP,
	SCREEN_SHAKE,
	FADE_IN,
	FADE_OUT
}

var _active_effects: Array = []

func _ready() -> void:
	pass

func play_card_flip(target: Node, duration: float = 0.3) -> void:
	var tween = create_tween()
	
	var initial_scale = target.scale
	
	tween.tween_property(target, "scale:x", 0.0, duration / 2.0)
	tween.tween_callback(func(): _flip_card(target))
	tween.tween_property(target, "scale:x", initial_scale.x, duration / 2.0)
	
	tween.tween_callback(func(): animation_finished.emit("card_flip"))

func _flip_card(target: Node) -> void:
	pass

func play_card_shake(target: Node, intensity: float = 5.0, duration: float = 0.3) -> void:
	var tween = create_tween()
	var original_pos = target.position
	
	var elapsed = 0.0
	while elapsed < duration:
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		target.position = original_pos + offset
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05
	
	target.position = original_pos
	animation_finished.emit("card_shake")

func play_score_popup(target: Node, score: int, position: Vector2, color: Color = Color.GREEN) -> void:
	var label = Label.new()
	label.text = "+%d" % score
	label.global_position = position
	label.modulate = color
	label.z_index = 100
	
	var viewport = target.get_viewport()
	if viewport:
		viewport.add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", position.y - 50, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	tween.tween_callback(label.queue_free)
	
	animation_finished.emit("score_popup")

func play_chips_popup(target: Node, chips: int, mult: int, position: Vector2) -> void:
	play_score_popup(target, chips, position, Color.CYAN)
	
	if mult > 1:
		var mult_pos = position + Vector2(50, 0)
		play_score_popup(target, 0, mult_pos, Color.YELLOW)

func play_screen_shake(duration: float = 0.3, intensity: float = 10.0) -> void:
	var viewport = get_viewport()
	if viewport == null:
		return
	
	var camera = viewport.get_camera_2d()
	if camera == null:
		var camera3d = Camera3D.new()
		viewport.add_child(camera3d)
		camera = camera3d
	
	var original_offset = Vector2.ZERO
	var tween = create_tween()
	
	var elapsed = 0.0
	while elapsed < duration:
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		camera.offset = offset
		await get_tree().create_timer(0.05).timeout
		elapsed += 0.05
	
	camera.offset = original_offset
	animation_finished.emit("screen_shake")

func play_fade_out(target: CanvasItem, duration: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(target, "modulate:a", 0.0, duration)
	tween.tween_callback(func(): animation_finished.emit("fade_out"))

func play_fade_in(target: CanvasItem, duration: float = 0.5) -> void:
	target.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(target, "modulate:a", 1.0, duration)
	tween.tween_callback(func(): animation_finished.emit("fade_in"))

func play_win_effect(target: Node) -> void:
	var original_scale = target.scale
	
	var tween = create_tween()
	tween.tween_property(target, "scale", original_scale * 1.2, 0.1)
	tween.tween_property(target, "scale", original_scale, 0.1)
	tween.tween_property(target, "scale", original_scale * 1.1, 0.1)
	tween.tween_property(target, "scale", original_scale, 0.1)
	
	animation_finished.emit("win_effect")

func play_lose_effect(target: Node) -> void:
	play_card_shake(target, 10.0, 0.5)
	animation_finished.emit("lose_effect")

func play_scale_bounce(target: Node, scale_factor: float = 1.2, duration: float = 0.2) -> void:
	var original_scale = target.scale
	
	var tween = create_tween()
	tween.tween_property(target, "scale", original_scale * scale_factor, duration / 2.0)
	tween.tween_property(target, "scale", original_scale, duration / 2.0)
	
	tween.tween_callback(func(): animation_finished.emit("scale_bounce"))

func play_color_flash(target: CanvasItem, color: Color, duration: float = 0.2) -> void:
	var original_modulate = target.modulate
	
	var tween = create_tween()
	tween.tween_property(target, "modulate", color, duration / 2.0)
	tween.tween_property(target, "modulate", original_modulate, duration / 2.0)
	
	tween.tween_callback(func(): animation_finished.emit("color_flash"))
