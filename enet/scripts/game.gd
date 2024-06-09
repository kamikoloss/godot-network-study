extends Node2D


const ADDRESS = "localhost"
const PORT = 4242


@export var _player_scene: PackedScene
@export var _network_nodes: Node2D


func _ready() -> void:
	var _is_server_mode = "--server" in OS.get_cmdline_args()
	_start_network(_is_server_mode)


func _start_network(is_server_mode: bool) -> void:
	var _peer = ENetMultiplayerPeer.new()

	# Server の場合
	if is_server_mode:
		multiplayer.peer_connected.connect(_on_peer_connected)
		multiplayer.peer_disconnected.connect(_on_peer_disconnected)
		_peer.create_server(PORT)
		print("server is listening on %s:$s" % [ADDRESS, PORT])
	# Client の場合
	else:
		_peer.create_client(ADDRESS, PORT)
		print("client connect to %s:%s" % [ADDRESS, PORT])

	multiplayer.multiplayer_peer = _peer


func _on_peer_connected(id: int) -> void:
	# Remote Peer の Player を作成する
	var _player = _player_scene.instantiate()
	_player.name = str(id)
	_network_nodes.add_child(_player)


func _on_peer_disconnected(id: int) -> void:
	# Remote Peer の Player を破棄する
	_network_nodes.get_node(str(id)).queue_free()
