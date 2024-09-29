extends CharacterBody2D
class_name EnemyFighterShip

@export var hit_points: int = 1
@export var stop_chasing_distance_near: int = 50
@export var firing_range_max: float = 190
@export var acceleration_rate: float = 0.95
@export var max_velocity: float = 38
@export var rotation_rate: float = 0.02

@export var bolt: PackedScene

var _is_dying: bool = false
var chasing_player: CharacterBody2D

enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

var facing_direction: float = 0

func _set_chasing_player():
	var players = get_tree().get_nodes_in_group("PlayerGroup")
	if players[0]:
		chasing_player = players[0]

func _physics_process(_delta: float) -> void:
	if ! chasing_player:
		_set_chasing_player()
	_handle_hp_check()
	_handle_obstacle_check()
	_chase_player()
	move_and_slide()

func _handle_hp_check():
	if _is_dying:
		return
	if hit_points <= 0:
		call_deferred("explode")

func _handle_obstacle_check():
	if _is_dying:
		return
	if $ObstacleDetector1.is_colliding() || $ObstacleDetector2.is_colliding():
		# TODO: decelerate
		velocity = Vector2(0, 0)

func explode():
	_is_dying = true
	$BoltCharging.emitting = false
	$AnimatedSprite2D.visible = false
	$Explosion.restart()

func _chase_player():
	if _is_dying:
		return
	if ! chasing_player:
		return
	if position.distance_to(chasing_player.position) > stop_chasing_distance_near:
		rotation = lerp_angle(rotation, rotation + get_angle_to(chasing_player.position), rotation_rate)
		velocity = _adjust_speed_for_rotation()

func _adjust_speed_for_rotation():
	return Vector2(
		clampf(velocity.x + acceleration_rate * cos(rotation), -max_velocity, max_velocity),
		clampf(velocity.y + acceleration_rate * sin(rotation), -max_velocity, max_velocity),
	)
	
func fire_bolt():
	var new_bolt = bolt.instantiate() as CharacterBody2D
	new_bolt.global_position = Vector2(global_position.x, global_position.y)
	new_bolt.look_at(chasing_player.global_position)
	new_bolt.velocity = Vector2(new_bolt.speed * cos(rotation), new_bolt.speed * sin(rotation))
	get_parent().add_child(new_bolt)

func _on_bolt_timer_timeout() -> void:
	if _is_dying:
		return
	if ! chasing_player:
		return
	if $BoltCharging.emitting:
		return
	if position.distance_to(chasing_player.position) < firing_range_max:
		$BoldChargingTimer.start()
		$BoltCharging.emitting = true


func _on_bold_charging_timer_timeout() -> void:
	if _is_dying:
		return
	$BoltCharging.emitting = false
	fire_bolt()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if _is_dying:
		return
	if body is Asteroid:
		hit_points -= 1


func _on_explosion_finished() -> void:
	queue_free()
