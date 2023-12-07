extends Control

@onready var name_label =$LabelName
@onready var kill_label = $LabelKill
@onready var death_label = $LabelDeath


func connect_signals(player:Player):
	player.killed.connect(update_player_kill)
	player.died.connect(update_player_death)

func set_player_name(player:Player):
	name_label = $LabelName
	name_label.set_text(player.name)
	
func set_player_kill(player:Player):
	kill_label = $LabelKill
	kill_label.text = str(player.kill_count)

	
func set_player_death(player:Player):
	death_label = $LabelDeath
	death_label.text = str(player.death_count)
	
func update_player_kill(killcount):
	kill_label.text = str(killcount)
	
func update_player_death(deathcount):
	death_label.text = str(deathcount)
