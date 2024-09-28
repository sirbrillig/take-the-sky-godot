extends CharacterBody2D
class_name Asteroid

var min_x = -10
var min_y = -10
var max_x = 10
var max_y = 10

func _ready() -> void:
	$AnimatedSprite2D.play()
	velocity = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))

func _physics_process(_delta: float) -> void:
	move_and_slide()
