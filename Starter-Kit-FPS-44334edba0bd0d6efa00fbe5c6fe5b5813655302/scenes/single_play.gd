extends Node3D

@onready var hud = $CanvasLayer/HUD
@onready var player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	connect_signals(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func connect_signals(node:Player):
		node.ammo_updated.connect(hud._on_player_ammo_updated)
		node.reloading_start.connect(hud._on_player_reloading_start)
		node.reloading_finish.connect(hud._on_player_reloading_finish)
		node.reload_interupt.connect(hud._on_player_reload_interupt)
		node.health_updated.connect(hud._on_player_health_updated)
