extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_coins(Global.gold_coins)
	update_health(Global.player_health)
	update_energy(Global.player_ship_energy)
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = ! get_tree().paused
	
func update_health(total: int) -> void:
	$HealthMeter/Meter.max_value = Global.player_max_health
	$HealthMeter/Meter.value = total
	
func update_coins(total: int) -> void:
	$CoinMeter/Coins.text = str(total)

func update_energy(total: int) -> void:
	$EnergyMeter/Meter.max_value = Global.player_ship_max_energy
	$EnergyMeter/Meter.value = total
