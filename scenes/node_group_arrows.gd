extends CanvasGroup
class_name NodeGroupArrows

@export var arrow_min_distance: float = 100
@export var arrow_radius: float = 45
@export var arrow_scene: PackedScene
@export var node_group_name: String

@onready var player = get_tree().get_nodes_in_group("PlayerGroup")[0]

var arrow_angle: float = 0.0
var is_arrow_visible: bool = false
var arrow_node_pairs = []

func _process(_delta: float) -> void:
	var _nodes = get_tree().get_nodes_in_group(node_group_name)
	for _node in _nodes:
		if arrow_node_pairs.any(func(arr): return arr.node == _node):
			continue
		_add_arrow(_node)
	var pairs_to_remove = []
	for pair in arrow_node_pairs:
		if ! pair.node || pair.node.is_queued_for_deletion() || ! pair.node.visible:
			pairs_to_remove.push_back(pair)
			continue
		if pair.node is DerelictShip && pair.node.visited:
			pairs_to_remove.push_back(pair)
			continue
		_draw_gate_arrow(pair.node, pair.arrow)
	for pair in pairs_to_remove:
		pair.arrow.queue_free()
		arrow_node_pairs.erase(pair)

func _add_arrow(node: Node2D):
	var arrow = arrow_scene.instantiate()
	var pair = {"arrow": arrow, "node": node}
	arrow_node_pairs.push_back(pair)
	player.add_child(arrow)

func _draw_gate_arrow(node: Node2D, arrow: Sprite2D):
	arrow.visible = false
	if Global.active_crewmember != Global.CrewMember.Pilot:
		return
	if player.position.distance_to(node.position) < arrow_min_distance:
		return
	arrow.visible = true
	arrow_angle = player.position.angle_to_point(node.position)
	var x_pos = cos(arrow_angle - player.rotation)
	var y_pos = sin(arrow_angle - player.rotation)
	arrow.position.x = arrow_radius * x_pos
	arrow.position.y = arrow_radius * y_pos
	arrow.look_at(node.position)
