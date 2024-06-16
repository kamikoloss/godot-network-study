extends Node


const ADDRESS = "ws://localhost:9080"


@export var _player_scene: PackedScene
@export var _network_nodes: Node2D
@export var _connect_button: Button


var mp_peer := WebSocketMultiplayerPeer.new()


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	_connect_button.pressed.connect(_on_connect_button_pressed)


func _on_peer_connected(id: int) -> void:
	# Remote Peer の Player を作成する
	print("[Client] peer (%s) is connected." % str(id))
	var _player = _player_scene.instantiate()
	_player.name = str(id)
	_network_nodes.add_child(_player)


func _on_peer_disconnected(id: int) -> void:
	# Remote Peer の Player を破棄する
	print("[Client] peer (%s) is disconnecred." % str(id))
	_network_nodes.get_node(str(id)).queue_free()


func _on_connect_button_pressed() -> void:
	var _error = mp_peer.create_client(ADDRESS)
	if _error == OK:
		print("[Client] succeeded to connect to %s" % ADDRESS)
	else:
		print("[Client] failed to connect to %s for %s" % [ADDRESS, _error])
	multiplayer.multiplayer_peer = mp_peer
