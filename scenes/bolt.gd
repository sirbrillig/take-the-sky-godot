extends CharacterBody2D

signal hit_something

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity)
	if collision != null:    
		hit_something.emit()    
		queue_free()  


func _on_timer_timeout() -> void:
	queue_free()
