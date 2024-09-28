extends Node2D

@export var asteroid: PackedScene

@onready var spawnArea = $LevelArea/LevelAreaRect.shape.extents
@onready var origin = $LevelArea/LevelAreaRect.global_position -  spawnArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.update_health(Global.player_health)
	$HUD.update_coins(Global.gold_coins)
	create_asteroids()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_player_ship_player_health_changed() -> void:
	$HUD.update_health(Global.player_health)


func _on_player_ship_player_coins_changed() -> void:
	$HUD.update_coins(Global.gold_coins)


func gen_random_pos() -> Vector2:
	var x = randf_range(origin.x, spawnArea.x)
	var y = randf_range(origin.y, spawnArea.y)
	return Vector2(x, y)
	
func create_asteroids() -> void:
	for n in 6:
		var rock = asteroid.instantiate() as Asteroid
		var rock_spawn_location = gen_random_pos()
		rock.position = rock_spawn_location
		var direction = randf_range(0, 2 * PI)
		rock.rotation = direction
		add_child(rock)
