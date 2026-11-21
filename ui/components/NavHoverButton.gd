extends Button
class_name NavHoverButton

const IDLE_ALPHA := 0.6
const HOVER_ALPHA := 1.0
const HOVER_SCALE := Vector2(1.15, 1.15)
const TWEEN_TIME := 0.1

var _hover_tween: Tween

func _ready() -> void:
	modulate.a = IDLE_ALPHA
	alignment = HORIZONTAL_ALIGNMENT_LEFT
	flat = true
	resized.connect(_update_pivot)
	mouse_entered.connect(_on_hover_enter)
	mouse_exited.connect(_on_hover_exit)
	focus_entered.connect(_on_hover_enter)
	focus_exited.connect(_on_hover_exit)
	call_deferred("_update_pivot")

func _update_pivot() -> void:
	pivot_offset = Vector2(0.0, size.y * 0.5)

func _on_hover_enter() -> void:
	if disabled:
		return
	_animate(HOVER_SCALE, HOVER_ALPHA)

func _on_hover_exit() -> void:
	_animate(Vector2.ONE, IDLE_ALPHA)

func _animate(target_scale: Vector2, target_alpha: float) -> void:
	if _hover_tween and _hover_tween.is_valid():
		_hover_tween.kill()
	_hover_tween = create_tween().set_parallel(true)
	_hover_tween.tween_property(self, "scale", target_scale, TWEEN_TIME).set_ease(Tween.EASE_OUT)
	_hover_tween.tween_property(self, "modulate:a", target_alpha, TWEEN_TIME).set_ease(Tween.EASE_IN)
