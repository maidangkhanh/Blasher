extends Node3D

const PLAYER = preload("res://objects/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()


func _init():
	var player_instance = PLAYER.instantiate()
	add_child(player_instance)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_player(peer_id):
	var player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id):
	var player =  get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
