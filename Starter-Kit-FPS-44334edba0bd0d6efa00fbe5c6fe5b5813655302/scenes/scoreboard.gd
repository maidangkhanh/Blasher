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
	score_instance.set_name(player.name)
	score_instance.set_player_name(player)
	score_instance.set_player_kill(player)
	score_instance.set_player_death(player)
	score_talble.add_child(score_instance)

func remove_player(player_name:String):
	var scoreboard_item = score_talble.get_node(player_name)
	scoreboard_item.queue_free()

func update_player(player:Player):
	var item = get_node(NodePath(player.name))
	item.set_player_kill(player)
	item.set_player_death(player)
	
