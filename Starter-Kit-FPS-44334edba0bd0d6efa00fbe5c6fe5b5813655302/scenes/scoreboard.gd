extends Control

@onready var player_score = preload("res://objects/scoreboard_item.tscn")
@onready var score_talble = $PanelContainer/MarginContainer/ScoreTable

func _input(event):
	if Input.is_action_just_pressed("scoreboard"):
		show()
		
	if Input.is_action_just_released("scoreboard"):
		hide()


func add_player(player:Player):
	var score_instance = player_score.instantiate()
	score_instance.set_player_name(player)
	score_instance.set_player_kill(player)
	score_instance.set_player_death(player)
	score_talble.add_child(score_instance)
