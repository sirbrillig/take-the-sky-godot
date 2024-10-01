extends CharacterBody2D
class_name DerelictShip

@export var ship_name: String
@export var coins = 10

var visited: bool = false

func explode():
	$Sprite2D.visible = false
	$Explosion.restart()

func _on_explosion_finished() -> void:
	queue_free()
