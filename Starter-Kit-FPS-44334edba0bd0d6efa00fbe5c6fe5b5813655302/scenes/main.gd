extends Node

@onready var main_menu =$CanvasLayer/MainMenu
@onready var address_entry = $CanvasLayer/MainMenu/MarginContainer/VBoxContainer/AddressEntry
@onready var players = $Players
@onready var hud = $CanvasLayer/HUD
@onready var scoreboard = $CanvasLayer/Scoreboard

const Player = preload("res://objects/player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _on_host_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)

	add_player(multiplayer.get_unique_id())

	upnp_setup()

func _on_join_button_pressed():
	main_menu.hide()
	hud.show()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer

func add_player(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	players.add_child(player)
	if player.is_multiplayer_authority():
		connect_signals(player)
	
	for n in players.get_children():
		if not n.is_multiplayer_authority():
			n.show_weapon_visual()
		if n is Player:
			scoreboard.add_player(n)

func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

func upnp_setup():
	var upnp = UPNP.new()

	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Discover Failed! Error %s" % discover_result)

	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP Invalid Gateway!")

	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port Mapping Failed! Error %s" % map_result)

	print("Success! Join Address: %s" % upnp.query_external_address())


func _on_multiplayer_spawner_spawned(node):
	for n in players.get_children():
		if not n.is_multiplayer_authority():
			n.change_weapon_visual.rpc(n.weapon_index)
			n.show_weapon_visual()
			
	if node.is_multiplayer_authority():
		connect_signals(node)


func connect_signals(node:Player):
		node.ammo_updated.connect(hud._on_player_ammo_updated)
		node.reloading_start.connect(hud._on_player_reloading_start)
		node.reloading_finish.connect(hud._on_player_reloading_finish)
		node.reload_interupt.connect(hud._on_player_reload_interupt)
		node.health_updated.connect(hud._on_player_health_updated)
