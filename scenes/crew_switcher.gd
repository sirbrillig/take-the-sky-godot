extends Node2D

func _get_next_crew(current: Global.CrewMember) -> Global.CrewMember:
	match current:
		Global.CrewMember.Pilot:
			return Global.CrewMember.Tactician
		Global.CrewMember.Tactician:
			return Global.CrewMember.Pilot
		_:
			return Global.CrewMember.Pilot


func _process(_delta: float) -> void:
	$PilotButton.disabled = Global.active_crewmember != Global.CrewMember.Pilot
	$TacticianButton.disabled = Global.active_crewmember != Global.CrewMember.Tactician
	if Input.is_action_just_pressed("crew_one"):
		Global.active_crewmember = Global.CrewMember.Pilot
	if Input.is_action_just_pressed("crew_two"):
		Global.active_crewmember = Global.CrewMember.Tactician
	if Input.is_action_just_pressed("crew_next"):
		Global.active_crewmember = _get_next_crew(Global.active_crewmember)
	if Input.is_action_just_pressed("crew_previous"):
		# There's only two right now but eventually this will have to change
		Global.active_crewmember = _get_next_crew(Global.active_crewmember)


func _on_pilot_button_pressed() -> void:
	Global.active_crewmember = Global.CrewMember.Pilot


func _on_tactician_button_pressed() -> void:
	Global.active_crewmember = Global.CrewMember.Tactician
