extends Node

@onready var ammo_hud = $"Gun HUD/Ammo"
@onready var reloading_text = $"Gun HUD/ReloadingText"
@onready var reloading_bar = $"Gun HUD/ReloadingBar"
@onready var reload_timer = $"Gun HUD/ReloadTimer"
@onready var health = $Health

func _on_player_ammo_updated(ammo_description):
	ammo_hud.text = str(ammo_description)

func _on_player_reloading_finish():
	reloading_bar.hide()
	reloading_text.hide()


func _on_player_reloading_start(reload_time):
	reloading_bar.value = 0
	reloading_bar.max_value = reload_time
	reload_timer.start(reload_time)
	reloading_bar.show()
	reloading_text.show()

func _process(_delta):
	if reload_timer.time_left >0:
		reloading_bar.value = reloading_bar.max_value - reload_timer.time_left


func _on_player_reload_interupt():
	reloading_bar.hide()
	reloading_text.hide()
	reload_timer.stop()


func _on_player_health_updated(health_value):
	print("health")
	health.text = str(health_value) + "%"
