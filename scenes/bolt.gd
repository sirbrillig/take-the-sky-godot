extends CharacterBody2D
class_name Bolt

@export var speed: float = 4.0

func _physics_process(_delta: float) -> void:
	var collision = move_and_collide(velocity)
	if collision != null:
		_explode()

func destroy():
	_explode()

func _explode():
	$Sprite2D.visible = false
	velocity = Vector2(0,0)
	$Explosion.restart()


func _on_timer_timeout() -> void:
	queue_free()


func _on_explosion_finished() -> void:
	queue_free()
