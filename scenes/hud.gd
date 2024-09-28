extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func update_health(total: int) -> void:
	$HealthMeter/PlayerHealth.text = str(total)
	
func update_coins(total: int) -> void:
	$CoinMeter/Coins.text = str(total)
