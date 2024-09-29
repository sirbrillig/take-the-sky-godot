extends CharacterBody2D
class_name PlayerShip

signal player_health_changed
signal player_coins_changed

@export var acceleration_rate: float = 0.8
@export var max_velocity: float = 40
@export var rotation_rate: float = 0.03
@export var post_hit_invincibility: float = 1.0

var is_being_hit: bool = false
var gate_arrow_angle: float = 0.0
var gate_arrow_radius = 50

enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

func _physics_process(_delta: float) -> void:
	_handle_movement()
	move_and_slide()

func _process(_delta: float) -> void:
	_draw_gate_arrow()

func _draw_gate_arrow():
	var gates = get_tree().get_nodes_in_group("Gates")
	if gates.size() < 1:
		return
	var gate = gates[0]
	gate_arrow_angle = position.angle_to_point(gate.position)
	var x_pos = cos(gate_arrow_angle - rotation)
	var y_pos = sin(gate_arrow_angle - rotation)
	$GateArrow.position.x = gate_arrow_radius * x_pos
	$GateArrow.position.y = gate_arrow_radius * y_pos
	$GateArrow.look_at(gate.position)

func _handle_movement():
	$EngineSprite.visible = false
	if is_being_hit:
		return
	if Input.is_action_pressed("ui_left"):
		rotation = adjust_rotation_for_direction(RotationDirection.COUNTERCLOCKWISE)
	if Input.is_action_pressed("ui_right"):
		rotation = adjust_rotation_for_direction(RotationDirection.CLOCKWISE)
		
	if Input.is_action_pressed("ui_up"):
		velocity = adjust_speed_for_rotation()
		$EngineSprite.visible = true

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

func _knockback(angle_of_hit: float):
	velocity = Vector2(0,0)
	var current_rotation = rotation
	var current_acceleration_rate = acceleration_rate
	rotation = angle_of_hit
	acceleration_rate = 70
	velocity = adjust_speed_for_rotation()
	rotation = current_rotation
	acceleration_rate = current_acceleration_rate

func _flash_from_hit():
	$ShipSprite.material.set_shader_parameter("alpha", 1)
	await get_tree().create_timer(0.05).timeout
	$ShipSprite.material.set_shader_parameter("alpha", 0)

func _on_player_hit(angle_of_hit: float):
	is_being_hit = true
	_flash_from_hit()
	_knockback(angle_of_hit)
	Global.player_health -= 1
	player_health_changed.emit()
	await get_tree().create_timer(post_hit_invincibility).timeout
	is_being_hit = false

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	if is_being_hit:
		return
	if body is Asteroid:
		var angle_of_hit: float = body.position.angle_to_point(position)
		_on_player_hit(angle_of_hit)
	if body is DerelictShip:
		Global.gold_coins += body.coins
		body.coins = 0
		player_coins_changed.emit()
	if body is Bolt:
		var angle_of_hit: float = body.position.angle_to_point(position)
		_on_player_hit(angle_of_hit)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area is Gate:
		get_tree().call_deferred("change_scene_to_file", "res://scenes/level_2.tscn")
