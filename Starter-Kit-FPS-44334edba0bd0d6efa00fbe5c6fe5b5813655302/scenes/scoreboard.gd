extends Control


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
