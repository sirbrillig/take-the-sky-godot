extends CharacterBody2D
class_name PlayerShip

signal player_health_changed
signal player_coins_changed
signal player_visited_ship

@export var acceleration_rate: float = 0.8
@export var bounce_deceleration_rate: float = 10
@export var dash_acceleration_rate: float = 100
@export var max_velocity: float = 40
@export var max_dash_velocity: float = 100
@export var rotation_rate: float = 0.03
@export var post_hit_invincibility: float = 1.0
@export var bolt_energy_cost: int = 4
@export var dash_energy_cost: int = 5
@export var dash_time: float = 1.2
@export var bolt: PackedScene

var is_being_hit: bool = false
var is_using_gate: bool = false
var is_dashing: bool = false


enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

func _physics_process(delta: float) -> void:
	_update_health_bar()
	_handle_movement()
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.move_toward(Vector2.ZERO, bounce_deceleration_rate)
		velocity = velocity.bounce(collision.get_normal())

func _update_health_bar():
	$TacticalShipOverlay/Panel/TextureProgressBar.max_value = Global.player_max_health
	$TacticalShipOverlay/Panel/TextureProgressBar.value = Global.player_health

func is_invincible():
	if is_being_hit:
		return true
	if is_using_gate:
		return true
	return false

func _toggle_engines(is_on: bool):
	if is_on:
		$EngineSprite.visible = true
		$Trail.emitting = true
	else:
		$EngineSprite.visible = false
		$Trail.emitting = false

func _handle_movement():
	if is_being_hit || is_using_gate || is_dashing:
		_toggle_engines(false)
		return
	if Input.is_action_pressed("ui_left"):
		rotation = _adjust_rotation_for_direction(RotationDirection.COUNTERCLOCKWISE)
	if Input.is_action_pressed("ui_right"):
		rotation = _adjust_rotation_for_direction(RotationDirection.CLOCKWISE)
		
	if Input.is_action_pressed("ui_up"):
		velocity = _adjust_speed_for_rotation()
		_toggle_engines(true)
	else:
		_toggle_engines(false)

	if Input.is_action_pressed("ui_down"):
		_decelerate()

	if Input.is_action_just_pressed("ui_accept"):
		if Global.active_crewmember == Global.CrewMember.Tactician:
			_attack()
		if Global.active_crewmember == Global.CrewMember.Pilot:
			_dash()

func _spend_energy(amount: int) -> bool:
	if Global.player_ship_energy >= amount:
		Global.player_ship_energy -= amount
		return true
	if Global.player_ship_energy > 0 and (Global.player_ship_energy + Global.gold_coins) >= amount:
		Global.gold_coins -= (amount - Global.player_ship_energy)
		Global.player_ship_energy = 0
		return true
	if Global.gold_coins >= amount:
		Global.gold_coins -= amount
		return true
	return false

func _dash():
	if Global.active_crewmember != Global.CrewMember.Pilot:
		return
	if is_dashing:
		return
	if not _spend_energy(dash_energy_cost):
		return
	is_dashing = true
	$DashEmitter.emitting = true
	var prev_accel = acceleration_rate
	var prev_max_velocity = max_velocity
	acceleration_rate = dash_acceleration_rate
	max_velocity = max_dash_velocity
	velocity = _adjust_speed_for_rotation()
	acceleration_rate = prev_accel
	max_velocity = prev_max_velocity
	await get_tree().create_timer(dash_time).timeout
	$DashEmitter.emitting = false
	velocity = _adjust_speed_for_rotation()
	is_dashing = false

func _attack():
	if Global.active_crewmember != Global.CrewMember.Tactician:
		return
	if not _spend_energy(bolt_energy_cost):
		return
	var new_bolt = bolt.instantiate() as CharacterBody2D
	new_bolt.global_position = Vector2($FirePosition.global_position.x, $FirePosition.global_position.y)
	new_bolt.rotation = rotation
	new_bolt.velocity = Vector2(new_bolt.speed * cos(rotation), new_bolt.speed * sin(rotation))
	get_parent().add_child(new_bolt)

func _adjust_speed_for_rotation():
	return Vector2(
		clampf(velocity.x + acceleration_rate * cos(rotation), -max_velocity, max_velocity),
		clampf(velocity.y + acceleration_rate * sin(rotation), -max_velocity, max_velocity),
	)
	
func _adjust_rotation_for_direction(dir: RotationDirection):
	if dir == RotationDirection.COUNTERCLOCKWISE:
		return rotation - rotation_rate
	else:
		return rotation + rotation_rate

func _decelerate():
	velocity = velocity.move_toward(Vector2.ZERO, acceleration_rate)

func _knockback(angle_of_hit: float):
	velocity = Vector2(0,0)
	var current_rotation = rotation
	var current_acceleration_rate = acceleration_rate
	rotation = angle_of_hit
	acceleration_rate = 70
	velocity = _adjust_speed_for_rotation()
	rotation = current_rotation
	acceleration_rate = current_acceleration_rate

func _flash_from_hit():
	$ShipSprite.material.set_shader_parameter("alpha", 1)
	await get_tree().create_timer(0.05).timeout
	$ShipSprite.material.set_shader_parameter("alpha", 0)

func _damage_player(amount: int):
	if is_invincible():
		return
	is_being_hit = true
	_flash_from_hit()
	$SmokeEmitter.emitting = true
	Global.player_health -= amount
	player_health_changed.emit()
	await get_tree().create_timer(post_hit_invincibility).timeout
	is_being_hit = false
	$SmokeEmitter.emitting = false

func _on_player_hit(angle_of_hit: float):
	if is_invincible():
		return
	_knockback(angle_of_hit)
	_damage_player(1)

func _on_area_2d_body_entered(body) -> void:
	if not body is CharacterBody2D:
		return
	if is_being_hit || is_using_gate:
		return
	if body.get_meta("collision_damage", 0):
		_damage_player(body.get_meta("collision_damage", 0))
	if body.get_meta("bounce_when_hit", false):
		var angle_of_hit: float = body.position.angle_to_point(position)
		_on_player_hit(angle_of_hit)
	if body.get_meta("stop_when_hit", false):
		velocity = Vector2.ZERO
	if body is DerelictShip and body.visible and not body.visited:
		if body.coins > 0:
			$GotStuffEmitter.emitting = true
			$GotStuffTimer.start()
		Global.gold_coins += body.coins
		body.coins = 0
		body.visited = true
		player_coins_changed.emit()
		player_visited_ship.emit(body.ship_name)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Gate and area.visible:
		velocity = Vector2.ZERO
		is_using_gate = true
		$ShipSprite.material.set_shader_parameter("alpha", 1)
		SceneTransition.transition()
		await SceneTransition.on_transition_finished
		$ShipSprite.material.set_shader_parameter("alpha", 0)
		is_using_gate = false
		get_tree().call_deferred("change_scene_to_file", "res://scenes/level_2.tscn")


func _on_player_ship_energy_timer_timeout() -> void:
	if Global.player_ship_energy < Global.player_ship_max_energy:
		Global.player_ship_energy += 1


func _on_got_stuff_timer_timeout() -> void:
	$GotStuffEmitter.emitting = false
