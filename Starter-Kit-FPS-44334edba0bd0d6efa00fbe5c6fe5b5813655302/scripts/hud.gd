extends CanvasLayer

@onready var ammo_hud = $"Gun HUD/Ammo"

func _on_health_updated(health):
	$Health.text = str(health) + "%"

func _on_player_ammo_updated(ammo_description):
	ammo_hud.text = str(ammo_description)
