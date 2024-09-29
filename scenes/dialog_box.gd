extends CanvasLayer
class_name DialogBox

signal dialog_done
signal dialog_skip

@export var skip_button_hold_ms: int = 1200
var skip_button_hold_start: int = 0
var is_skip_button_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		dialog_done.emit()
	if Input.is_action_just_pressed("skip_dialog"):
		_handle_press_skip()
	if is_skip_button_pressed:
		_handle_hold_skip()
	if Input.is_action_just_released("skip_dialog"):
		_handle_release_skip()

func _handle_press_skip():
	skip_button_hold_start = Time.get_ticks_msec()
	is_skip_button_pressed = true

func _handle_release_skip():
	skip_button_hold_start = 0
	is_skip_button_pressed = false
	$SkipButton/AnimatedSprite2D.visible = false

func _handle_hold_skip():
	var skip_button_frame_count = 5
	var time_per_frame = int(floor(float(skip_button_hold_ms) / skip_button_frame_count))
	var time_elapsed = Time.get_ticks_msec() - skip_button_hold_start
	$SkipButton/AnimatedSprite2D.visible = true
	$SkipButton/AnimatedSprite2D.frame = int(floor(float(time_elapsed) / time_per_frame))
	if time_elapsed > skip_button_hold_ms:
		dialog_skip.emit()

func set_text(text: String) -> void:
	$TextArea.text  = text


func _on_next_button_pressed() -> void:
	dialog_done.emit()

func _on_next_button_blink_timer_timeout() -> void:
	$NextButton.visible = ! $NextButton.visible

func _on_skip_button_button_down() -> void:
	_handle_press_skip()

func _on_skip_button_button_up() -> void:
	_handle_release_skip()
