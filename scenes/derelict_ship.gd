extends CharacterBody2D
class_name DerelictShip

@export var coins = 10

func explode():
	$Sprite2D.visible = false
	$Explosion.restart()

func _on_explosion_finished() -> void:
	queue_free()
