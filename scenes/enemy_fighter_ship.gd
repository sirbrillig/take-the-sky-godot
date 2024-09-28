extends CharacterBody2D
class_name EnemyFighterShip

@export var hit_points: int = 1
@export var stop_chasing_distance_near: int = 50
@export var firing_range_max: float = 190
@export var acceleration_rate: float = 0.95
@export var max_velocity: float = 38
@export var rotation_rate: float = 0.02

@export var bolt: PackedScene

var chasing_player: CharacterBody2D

enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

var facing_direction: float = 0

func _physics_process(delta: float) -> void:
	var players = get_tree().get_nodes_in_group("PlayerGroup")
	if players[0]:
		chasing_player = players[0]
		chase_player(players[0], delta)

func chase_player(player: CharacterBody2D, delta: float):
	if position.distance_to(player.position) > stop_chasing_distance_near:
		rotation = lerp_angle(rotation, rotation + get_angle_to(player.position), rotation_rate)
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

func fire_bolt():
	var new_bolt = bolt.instantiate() as CharacterBody2D
	new_bolt.global_position = Vector2(global_position.x, global_position.y)
	new_bolt.look_at(chasing_player.global_position)
	new_bolt.velocity = Vector2(new_bolt.speed * cos(rotation), new_bolt.speed * sin(rotation))
	get_parent().add_child(new_bolt)

func _on_bolt_timer_timeout() -> void:
	if ! chasing_player:
		return
	if $BoltCharging.emitting:
		return
	if position.distance_to(chasing_player.position) < firing_range_max:
		$BoldChargingTimer.start()
		$BoltCharging.emitting = true


func _on_bold_charging_timer_timeout() -> void:
	$BoltCharging.emitting = false
	fire_bolt()
