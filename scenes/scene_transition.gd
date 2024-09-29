extends CanvasLayer

signal on_transition_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "fade_out":
		on_transition_finished.emit()
		animation_player.play("fade_in")
	if anim_name == "fade_in":
		color_rect.visible = false

func transition():
	color_rect.visible = true
	animation_player.play("fade_out")