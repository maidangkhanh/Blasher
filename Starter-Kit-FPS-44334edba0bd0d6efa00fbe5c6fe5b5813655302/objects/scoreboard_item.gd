extends Control

@onready var name_label =$LabelName
@onready var kill_label = $LabelKill
@onready var death_label = $LabelDeath


func set_player_name(player:Player):
	name_label = $LabelName
	name_label.set_text(player.name)
	
func set_player_kill(player:Player):
	kill_label = $LabelKill
	kill_label.text = str(player.kill_count)

	
func set_player_death(player:Player):
	death_label = $LabelDeath
	death_label.text = str(player.death_count)
	
