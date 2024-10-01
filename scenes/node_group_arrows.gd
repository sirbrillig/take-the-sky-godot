extends CanvasGroup
class_name NodeGroupArrows

@export var arrow_min_distance: float = 100
@export var arrow_radius: float = 45
@export var arrow_scene: PackedScene
@export var node_group_name: String

@onready var player = get_parent()

var arrow_angle: float = 0.0
var is_arrow_visible: bool = false
var arrow_ship_pairs = []

func _process(_delta: float) -> void:
	var ships = get_tree().get_nodes_in_group(node_group_name)
	for ship in ships:
		if arrow_ship_pairs.any(func(arr): return arr.ship == ship):
			continue
		_add_arrow(ship)
	var pairs_to_remove = []
	for pair in arrow_ship_pairs:
		if ! pair.ship || pair.ship.is_queued_for_deletion():
			pairs_to_remove.push_back(pair)
			continue
		_draw_gate_arrow(pair.ship, pair.arrow)
	for pair in pairs_to_remove:
		pair.arrow.queue_free()
		arrow_ship_pairs.erase(pair)

func _add_arrow(ship: CharacterBody2D):
	var arrow = arrow_scene.instantiate()
	var pair = {"arrow": arrow, "ship": ship}
	arrow_ship_pairs.push_back(pair)
	player.add_child(arrow)

func _draw_gate_arrow(ship: CharacterBody2D, arrow: Sprite2D):
	arrow.visible = false
	if player.position.distance_to(ship.position) < arrow_min_distance:
		return
	arrow.visible = true
	arrow_angle = player.position.angle_to_point(ship.position)
	var x_pos = cos(arrow_angle - player.rotation)
	var y_pos = sin(arrow_angle - player.rotation)
	arrow.position.x = arrow_radius * x_pos
	arrow.position.y = arrow_radius * y_pos
	arrow.look_at(ship.position)
