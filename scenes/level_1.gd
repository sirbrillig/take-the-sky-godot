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
	_ensure_enemies_exist()

func _ensure_enemies_exist():
	if ! have_enemies_activated:
		return
	var ships = get_tree().get_nodes_in_group("EnemyShips")
	var missing_ship_count = enemy_ship_count - ships.size()
	_activate_enemy_ships(missing_ship_count)

func _begin_part_2():
	have_enemies_activated = true
	$PlayerShip.is_gate_arrow_visible = true
	$Gate.visible = true
	$DerelictShip.explode()
	
func _activate_enemy_ships(count: int):
	for n in count:
		var enemy = enemy_ship.instantiate()
		enemy.position = _generate_random_vec(enemyOrigin, enemyArea)
		call_deferred("add_child", enemy)

func _on_player_ship_player_health_changed() -> void:
	$HUD.update_health(Global.player_health)


func _on_player_ship_player_coins_changed() -> void:
	$HUD.update_coins(Global.gold_coins)
	if ! have_enemies_activated:
		$DialogueControl.start_dialogue("searching ship")
		await $DialogueControl.on_dialog_closed
		_begin_part_2()

func _generate_random_vec(orig, area) -> Vector2:
	var x = randf_range(orig.x, area.x)
	var y = randf_range(orig.y, area.y)
	return Vector2(x, y)
	
func create_asteroids() -> void:
	for n in asteroid_count:
		var rock = asteroid.instantiate() as Asteroid
		var rock_spawn_location = _generate_random_vec(asteroidOrigin, asteroidArea)
		while rock_spawn_location.distance_to($PlayerShip.position) < too_close_distance:
			rock_spawn_location = _generate_random_vec(asteroidOrigin, asteroidArea)
		rock.position = rock_spawn_location
		var direction = randf_range(0, 2 * PI)
		rock.rotation = direction
		add_child(rock)

func _on_convo_1_timer_timeout() -> void:
	$DialogueControl.start_dialogue("start")
