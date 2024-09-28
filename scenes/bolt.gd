extends CharacterBody2D
class_name Bolt

signal hit_something

@export var speed: float = 4.0

func _physics_process(_delta: float) -> void:
	var collision = move_and_collide(velocity)
	if collision != null:
		if (collision.get_collider().name == 'PlayerShip'):
			collision.get_collider()._on_player_hit()
		hit_something.emit()
		queue_free()


func _on_timer_timeout() -> void:
	queue_free()
