extends CharacterBody2D
class_name Asteroid

@export var max_hit_points: int = 5
@export var hit_points: int = 5

var _is_dying: bool = false

var min_x = -10
var min_y = -10
var max_x = 10
var max_y = 10

func _ready() -> void:
	$AnimatedSprite2D.play()
	velocity = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))

func _physics_process(_delta: float) -> void:
	_handle_hp_check()
	move_and_slide()

func _explode():
	_is_dying = true
	$CollisionShape2D.disabled = true
	$Area2D/CollisionShape2D.disabled = true
	$AnimatedSprite2D.visible = false
	$Explosion.restart()

func _handle_hp_check():
	if _is_dying:
		return
	if hit_points <= 0:
		call_deferred("_explode")

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if body.get_meta("stop_when_hit", false):
		velocity = Vector2.ZERO
	if body is Bolt or body is PlayerBolt:
		hit_points -= 1
		body.destroy()

func _on_explosion_finished() -> void:
	queue_free()
