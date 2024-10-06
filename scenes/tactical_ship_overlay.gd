extends CanvasGroup


func _process(_delta: float) -> void:
	visible = Global.active_crewmember == Global.CrewMember.Tactician
