extends Node2D

@export var enemy_ship: PackedScene
@export var asteroid: PackedScene
@export var asteroid_count: int = 40
@export var enemy_ship_count: int = 2
@export var too_close_distance: float = 70

var have_enemies_activated: bool = false

@onready var asteroidArea = $AsteroidArea/AsteroidAreaRect.shape.extents
@onready var asteroidOrigin = $AsteroidArea/AsteroidAreaRect.global_position -  asteroidArea
@onready var enemyArea = $EnemyShipSpawnArea/EnemyShipSpawnRect.shape.extents
@onready var enemyOrigin = $EnemyShipSpawnArea/EnemyShipSpawnRect.global_position -  enemyArea

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.update_health(Global.player_health)
	$HUD.update_coins(Global.gold_coins)
	create_asteroids()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
	
func activate_enemy_ships():
	for n in enemy_ship_count:
		var enemy = enemy_ship.instantiate()
		enemy.position = gen_random_pos(enemyOrigin, enemyArea)
		call_deferred("add_child", enemy)

func _on_player_ship_player_health_changed() -> void:
	$HUD.update_health(Global.player_health)


func _on_player_ship_player_coins_changed() -> void:
	$HUD.update_coins(Global.gold_coins)
	if ! have_enemies_activated:
		have_enemies_activated = true
		activate_enemy_ships()

func gen_random_pos(orig, area) -> Vector2:
	var x = randf_range(orig.x, area.x)
	var y = randf_range(orig.y, area.y)
	return Vector2(x, y)
	
func create_asteroids() -> void:
	for n in asteroid_count:
		var rock = asteroid.instantiate() as Asteroid
		var rock_spawn_location = gen_random_pos(asteroidOrigin, asteroidArea)
		while rock_spawn_location.distance_to($PlayerShip.position) < too_close_distance:
			rock_spawn_location = gen_random_pos(asteroidOrigin, asteroidArea)
		rock.position = rock_spawn_location
		var direction = randf_range(0, 2 * PI)
		rock.rotation = direction
		add_child(rock)
