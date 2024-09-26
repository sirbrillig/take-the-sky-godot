extends CharacterBody2D
class_name EnemyFighterShip

@export var hit_points: int = 1
@export var stop_chasing_distance_near: int = 40
@export var acceleration_rate: float = 3
@export var max_velocity: float = 40
@export var rotation_rate: float = 0.06 # TODO use this

enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

func _physics_process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("PlayerGroup")
	if players[0]:
		chase_player(players[0], delta)

func chase_player(player: CharacterBody2D, delta: float):
	if position.distance_to(player.position) > stop_chasing_distance_near:
		look_at(player.position)
		velocity = adjust_speed_for_rotation()
		move_and_collide(velocity * delta)
	else:
		# TODO: slow down instead of stopping
		velocity = Vector2(0, 0)

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
