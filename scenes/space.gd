extends Node2D

@export var enemy_ship: PackedScene
var have_enemies_activated: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$HUD.update_health(Global.player_health)
	$HUD.update_coins(Global.gold_coins)


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
	# TODO: this script part should not be shared between levels
	$HUD.update_coins(Global.gold_coins)
	if ! have_enemies_activated:
		have_enemies_activated = true
		activate_enemy_ships()
