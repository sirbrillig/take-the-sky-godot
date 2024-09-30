extends Node
class_name DialogueControl

signal on_dialog_closed

@export var speaker1: Color = '#f69307'
@export var speaker2: Color = '#22e300'
@export var speaker3: Color = '#ffffff'
@export var speaker4: Color = '#c1c900'
@export var dialogue_file_name: String

var box_class = preload("res://scenes/dialog_box.tscn")
var panel: DialogBox
var clyde: ClydeDialogue

func _ready() -> void:
	_init_dialogue()

func _get_speaker_color(speaker: String) -> String:
	match speaker:
		"Yard":
			return speaker1.to_html()
		"Dash":
			return speaker4.to_html()
		"Capt":
			return speaker2.to_html()
		_:
			return speaker3.to_html()

func start_dialogue(block: String) -> void:
	if ! clyde:
		assert(false, "No dialogue_file_name set")
		return
	clyde.start(block)
	panel = box_class.instantiate() as DialogBox
	panel.dialog_done.connect(_on_convo_continues)
	panel.dialog_skip.connect(_on_convo_complete)
	get_tree().paused = true
	add_child(panel)
	_on_convo_continues()

func _init_dialogue() -> void:
	clyde = ClydeDialogue.new()
	clyde.load_dialogue(dialogue_file_name)
	
func _on_convo_continues() -> void:
	var content = clyde.get_content()
	if content.type == 'end':
		_on_convo_complete()
		return
	if content.speaker:
		var speaker_color = _get_speaker_color(content.speaker)
		panel.set_text(
			'[color={color}]'.format({"color": speaker_color})
			+ content.speaker + ':[/color] ' + content.text)
	else:
		panel.set_text(content.text)

func _on_convo_complete() -> void:
	panel.queue_free()
	get_tree().paused = false
	on_dialog_closed.emit()
