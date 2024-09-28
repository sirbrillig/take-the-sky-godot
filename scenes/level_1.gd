extends Node2D

@export var enemy_ship: PackedScene
@export var asteroid: PackedScene

var have_enemies_activated: bool = false

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
	
	
func activate_enemy_ships():
	for n in 3:
		var enemy = enemy_ship.instantiate()
		enemy.position = $EnemyShipSpawnPoint.position + Vector2(randf_range(10, 20), randf_range(10, 20))
		add_child(enemy)

func _on_player_ship_player_health_changed() -> void:
	$HUD.update_health(Global.player_health)


func _on_player_ship_player_coins_changed() -> void:
	$HUD.update_coins(Global.gold_coins)
	if ! have_enemies_activated:
		have_enemies_activated = true
		activate_enemy_ships()

func gen_random_pos() -> Vector2:
	var x = randf_range(origin.x, spawnArea.x)
	var y = randf_range(origin.y, spawnArea.y)
	return Vector2(x, y)
	
func create_asteroids() -> void:
	for n in 50:
		var rock = asteroid.instantiate() as Asteroid
		var rock_spawn_location = gen_random_pos()
		rock.position = rock_spawn_location
		var direction = randf_range(0, 2 * PI)
		rock.rotation = direction
		add_child(rock)
