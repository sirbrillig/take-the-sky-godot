extends CharacterBody2D
class_name EnemyFighterShip

@export var hit_points: int = 1
@export var acceleration_rate: float = 5
@export var max_velocity: float = 60
@export var rotation_rate: float = 0.06

var speed = 30 # TODO replace with acceleration

enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

func _physics_process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("PlayerGroup")
	if players[0] and position.distance_to(players[0].position) > 10:
		# TODO: face player
		velocity = position.direction_to(players[0].position) * speed
		move_and_slide()

func adjust_speed_for_rotation():
	return Vector2(
		clampf(velocity.x + acceleration_rate * cos(rotation), -max_velocity, max_velocity),
		clampf(velocity.y + acceleration_rate * sin(rotation), -max_velocity, max_velocity),
	)
	
func adjust_rotation_for_direction(dir: RotationDirection):
	if dir == RotationDirection.COUNTERCLOCKWISE:
		return rotation - rotation_rate
	else:
		return rotation + rotation_rate
