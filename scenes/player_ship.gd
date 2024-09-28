extends CharacterBody2D
class_name PlayerShip

signal player_health_changed
signal player_coins_changed

@export var acceleration_rate: float = 0.8
@export var max_velocity: float = 40
@export var rotation_rate: float = 0.03

enum RotationDirection {CLOCKWISE, COUNTERCLOCKWISE}

func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		rotation = adjust_rotation_for_direction(RotationDirection.COUNTERCLOCKWISE)
	if Input.is_action_pressed("ui_right"):
		rotation = adjust_rotation_for_direction(RotationDirection.CLOCKWISE)
		
	if Input.is_action_pressed("ui_up"):
		velocity = adjust_speed_for_rotation()
		$EngineSprite.visible = true
	else:
		$EngineSprite.visible = false

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

func _knockback(angle_of_hit: float):
	velocity = Vector2(0,0)
	var current_rotation = rotation
	var current_acceleration_rate = acceleration_rate
	rotation = angle_of_hit
	acceleration_rate = 70
	velocity = adjust_speed_for_rotation()
	rotation = current_rotation
	acceleration_rate = current_acceleration_rate

func _on_player_hit(angle_of_hit: float):
	_knockback(angle_of_hit)
	Global.player_health -= 1
	player_health_changed.emit()

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
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
