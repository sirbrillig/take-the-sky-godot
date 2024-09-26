extends CharacterBody2D
class_name EnemyFighterShip

@export var hit_points: int = 1
@export var stop_chasing_distance_near: int = 10
@export var acceleration_rate: float = 5
@export var max_velocity: float = 60
@export var rotation_rate: float = 0.06

var speed = 30 # TODO replace with acceleration

enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

func _physics_process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("PlayerGroup")
	if players[0]:
		chase_player(players[0])
		move_and_slide()

func chase_player(player: CharacterBody2D):
	if position.distance_to(player.position) > stop_chasing_distance_near:
		look_at(player.position)
		velocity = position.direction_to(player.position) * speed

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
