extends CanvasLayer
class_name DialogBox

signal dialog_done

@onready var text_area = get_node("./TextArea")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		dialog_done.emit()

func set_text(text: String) -> void:
	text_area.text  = text


func _on_next_button_pressed() -> void:
	dialog_done.emit()


func _on_next_button_blink_timer_timeout() -> void:
	$NextButton.visible = ! $NextButton.visible
