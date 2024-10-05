extends CharacterBody2D
class_name PlayerShip

signal player_health_changed
signal player_coins_changed
signal player_visited_ship

@export var acceleration_rate: float = 0.8
@export var max_velocity: float = 40
@export var rotation_rate: float = 0.03
@export var post_hit_invincibility: float = 1.0

@export var bolt: PackedScene

var is_being_hit: bool = false
var is_using_gate: bool = false


enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

func _physics_process(_delta: float) -> void:
	_update_health_bar()
	_handle_movement()
	move_and_slide()

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
	if is_being_hit || is_using_gate:
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
		_attack()

func _attack():
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

func _on_player_hit(angle_of_hit: float):
	if is_invincible():
		return
	is_being_hit = true
	_flash_from_hit()
	$SmokeEmitter.emitting = true
	_knockback(angle_of_hit)
	Global.player_health -= 1
	player_health_changed.emit()
	await get_tree().create_timer(post_hit_invincibility).timeout
	is_being_hit = false
	$SmokeEmitter.emitting = false

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if is_being_hit || is_using_gate:
		return
	if body.get_meta("bounce_when_hit", false):
		var angle_of_hit: float = body.position.angle_to_point(position)
		_on_player_hit(angle_of_hit)
	if body.get_meta("stop_when_hit", false):
		velocity = Vector2.ZERO
	if body is DerelictShip and body.visible:
		Global.gold_coins += body.coins
		body.coins = 0
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
