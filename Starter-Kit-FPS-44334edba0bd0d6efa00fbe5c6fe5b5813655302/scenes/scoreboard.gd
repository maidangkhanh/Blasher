extends Control

@onready var player_score = preload("res://objects/PlayerScore.tscn")
@onready var score_talble = $PanelContainer/MarginContainer/ScoreTable
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _input(event):
	if Input.is_action_just_pressed("scoreboard"):
		show()
		
	if Input.is_action_just_released("scoreboard"):
		hide()


func add_player(name:String):
	var score_instance = player_score.instantiate()
	var name_label:Label = score_instance.get_node("Container/LabelName")
	name_label.set_text(name)
	
	score_talble.add_child(score_instance)
