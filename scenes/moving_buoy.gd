extends CharacterBody2D

@export var speed: float = 50.0
@export var left_right: bool = true

enum MovementDirection {First, Second}
var direction: MovementDirection = MovementDirection.Second

func _physics_process(delta: float) -> void:
	if direction == MovementDirection.Second:
		if left_right:
			velocity.x = speed
		else:
			velocity.y = speed
	else:
		if left_right:
			velocity.x = -speed
		else:
			velocity.y = -speed
	var collision = move_and_collide(velocity * delta)
	if collision:
		if direction == MovementDirection.Second:
			direction = MovementDirection.First
		else:
			direction = MovementDirection.Second
