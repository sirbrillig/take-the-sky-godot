extends Node

enum CrewMember {Pilot, Tactician}

var player_max_health := 10
var player_health := 10
var gold_coins := 0
var player_ship_energy := 10
var player_ship_max_energy := 10
var active_crewmember: CrewMember = CrewMember.Pilot
