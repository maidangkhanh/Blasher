extends Control

@onready var name_label = $Container/LabelName
@onready var kill_label = $Container/LabelKill
@onready var death_label = $Container/LabelDeath

func set_player_name(player:Player):
	name_label.set_text(player.name)
	
func set_player_kill(player:Player):
	kill_label.set_text(player.score.kill_count)
	
func set_player_death(player:Player):
	death_label.set_text(player.score.death_count)
