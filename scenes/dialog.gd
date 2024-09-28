extends CanvasLayer
class_name Dialog

signal dialog_done

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		dialog_done.emit()

func set_text(text: String) -> void:
	$TextArea.text  = text
