extends Node2D


const ADDRESS = "ws://localhost"
const PORT = 8080


# WebSocket
@export var _ws_client: WebSocketClient
@export var _send_interval: float = 0.05

# Nodes
@export var _player: Player
@export var _network_nodes: Node

# UI
@export var _connect_button: Button
@export var _ping_label: Label
@export var _ping_avg_label: Label
@export var _ping_refresh_interval: float = 0.25

# Scenes
@export var _player_scene: PackedScene


var _send_timer: float = 0.0
var _other_players: Dictionary = {}

# Ping
var _ping_refresh_timer: float = 0.0
var _recent_ping_list: Array[float] = []
var _recent_ping_list_max_size: int = 10


func _ready() -> void:
	_ws_client.connected_to_server.connect(_on_web_socket_client_connected_to_server)
	_ws_client.connection_closed.connect(_on_web_socket_client_connection_closed)
	_ws_client.message_received.connect(_on_web_socket_client_message_received)
	_connect_button.pressed.connect(_on_connect_button_pressed)


func _process(delta: float) -> void:
	_process_send(delta)
	_process_refresh_ping(delta)


func _on_web_socket_client_connected_to_server():
	print("[Client] Connected to server!")


func _on_web_socket_client_connection_closed():
	print("[Client] Connection closed.")


func _on_web_socket_client_message_received(message: Variant):
	#print("[Client] Message received from server. Message: %s" % [message])

	# time
	var ping = Time.get_unix_time_from_system() - message["time"]
	_recent_ping_list.append(ping)
	if _recent_ping_list_max_size < _recent_ping_list.size():
		_recent_ping_list.pop_front()
	#print(_recent_ping_list)

	# players
	for peer_id in message["players"]:
		# Player が未作成の場合: 作成する
		if not _other_players.has(peer_id):
			var other_player = _player_scene.instantiate()
			_network_nodes.add_child(other_player)
			_other_players[peer_id] = other_player
		# Player を移動させる
		_other_players[peer_id].position = message["players"][peer_id]["position"]



func _on_connect_button_pressed():
	var _error = _ws_client.connect_to_url("%s:%s" % [ADDRESS, PORT])
	if _error == OK:
		print("[Client] connect_to_url OK")
	else:
		print("[Client] connect_to_url NG: %s" % error_string(_error))


# サーバーにデータを送信する
func _process_send(delta: float) -> void:
	if _ws_client.last_state != WebSocketPeer.STATE_OPEN:
		return
	_send_timer += delta
	if _send_timer < _send_interval:
		return
	_send_timer = 0.0

	var message = {
		"position": _player.position,
	}
	_ws_client.send(message)


# Ping の表示を更新する
func _process_refresh_ping(delta: float) -> void:
	if _recent_ping_list.is_empty():
		return
	_ping_refresh_timer += delta
	if _ping_refresh_timer < _ping_refresh_interval:
		return
	_ping_refresh_timer = 0.0

	var ping_sum = _recent_ping_list.reduce(func(a, n): return a + n, 0.0)
	var ping_avg = ping_sum / _recent_ping_list.size()
	_ping_label.text = "Ping: %s ms" % str(snappedf(_recent_ping_list[-1] * 1000, 0.01))
	_ping_avg_label.text = "(Avg: %s ms)" % str(snappedf(ping_avg * 1000, 0.01))
