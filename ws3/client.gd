extends Node2D


const ADDRESS = "wss://ws.gloxi.net/ws3"
const PORT = 443
#const ADDRESS = "ws://localhost"
#const PORT = 8003


# WebSocket
@export var _ws_client: WebSocketClient
@export var _send_interval: float = 0.05

# Nodes
@export var _player: Player
@export var _network_nodes: Node

# UI
@export var _connect_button: Button
@export var _ping_current_label: Label
@export var _ping_average_label: Label
@export var _ping_refresh_interval: float = 0.25

# Scenes
@export var _player_scene: PackedScene


var _send_timer: float = 0.0
var _player_id: int = 0
var _other_players: Dictionary = {}
var _other_players_tween: Dictionary = {}

# Ping
var _ping_refresh_timer: float = 0.0
var _recent_ping_list: Array[float] = []
var _recent_ping_list_max_size: int = 50



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
	_connect_button.disabled = true


func _on_web_socket_client_connection_closed():
	print("[Client] Connection closed.")
	_connect_button.disabled = false


func _on_web_socket_client_message_received(message: Variant):
	#print("[Client] Message received from server. Message: %s" % [message])

	if not message.has("type"):
		return
	match message["type"]:
		1:
			_on_received_connected(message)
		2:
			_on_received_players(message)


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
		"time": Time.get_unix_time_from_system(),
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
	_ping_current_label.text = "Current: %s ms" % str(snappedf(_recent_ping_list[-1] * 1000, 0.01))
	_ping_average_label.text = "Average: %s ms" % str(snappedf(ping_avg * 1000, 0.01))


# 接続完了を受信したときの処理
func _on_received_connected(message: Variant) -> void:
	if message.has("id"):
		_player_id = message["id"]
		print("[Client] my player id: %s" % _player_id)


# プレイヤー情報を受信したときの処理
func _on_received_players(message: Variant) -> void:
	var players = message["players"]
	if players.is_empty():
		return
	if players[_player_id].is_empty():
		return

	# time
	# サーバーに送信した Unixtime を元に ping を計算する
	var time = players[_player_id]["time"]
	var ping = Time.get_unix_time_from_system() - time
	_recent_ping_list.append(ping)
	if _recent_ping_list_max_size < _recent_ping_list.size():
		_recent_ping_list.pop_front()

	# 自プレイヤーの情報を削除する (これ以降の処理で不要なため)
	players.erase(_player_id)

	# position
	for peer_id in players:
		if players[peer_id].is_empty():
			continue
		var other_player: Player = null
		var pos = players[peer_id]["position"]

		# 他プレイヤーがまだ未作成の場合: 作成する (出現する)
		if not _other_players.has(peer_id):
			other_player = _player_scene.instantiate()
			other_player.position = players[peer_id]["position"]
			other_player.is_other = false
			_network_nodes.add_child(other_player)
			_other_players[peer_id] = other_player
		else:
			other_player = _other_players[peer_id]

		# 他プレイヤーの座標を同期する
		#other_player.position = pos
		if _other_players_tween.has(peer_id):
			_other_players_tween[peer_id].kill()
		_other_players_tween[peer_id] = create_tween()
		_other_players_tween[peer_id].tween_property(other_player, "position", pos, 0.05)
