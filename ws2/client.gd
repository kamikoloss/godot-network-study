extends Node


const ADDRESS = "ws://localhost:9090"


@export var _player_scene: PackedScene
@export var _network_nodes: Node2D
@export var _connect_button: Button

@export var _player_name: String = "Player"


var mp_peer := WebSocketMultiplayerPeer.new()
var peer := WebSocketPeer.new()


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	_connect_button.pressed.connect(_on_connect_button_pressed)


func _on_connected_to_server() -> void:
	print("[Client %s] connected to server." % _player_name)


func _on_connection_failed() -> void:
	print("[Client %s] connection failed." % _player_name)


func _on_peer_connected(id: int) -> void:
	print("[Client %s] peer (%s) connected." % [_player_name, str(id)])
	var _player = _player_scene.instantiate()
	_player.name = str(id)
	_network_nodes.add_child(_player)


func _on_peer_disconnected(id: int) -> void:
	print("[Client %s] peer (%s) disconnecred." % [_player_name, str(id)])
	_network_nodes.get_node(str(id)).queue_free()


func _on_server_disconnected() -> void:
	print("[Client %s] server disconnected." % _player_name)


func _on_connect_button_pressed() -> void:
	var _error = mp_peer.create_client(ADDRESS)
	#var _error = peer.connect_to_url(ADDRESS)

	if _error == OK:
		print("[Client %s] succeeded to connect to %s" % [_player_name, ADDRESS])
	else:
		print("[Client %s] failed to connect to %s for %s" % [_player_name, ADDRESS, error_string(_error)])
	multiplayer.multiplayer_peer = mp_peer
