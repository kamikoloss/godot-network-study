extends Node2D


const ADDRESS = "ws://localhost"
const PORT = 8080

@export var _web_socket_client: WebSocketClient
@export var _player: Player
# UI
@export var _connect_button: Button
@export var _ping_label: Label
@export var _ping_avg_label: Label

@export var _send_interval: float = 0.05
@export var _ping_refresh_interval: float = 0.25


var _send_timer: float = 0.0
# Ping
var _ping_refresh_timer: float = 0.0
var _recent_ping_list: Array[float] = []
var _recent_ping_list_max_size: int = 10
# 接続しているプレイヤーの情報
# { <PeerID>: { "position": <Vector2> } }
var _players: Dictionary = {}


func _ready() -> void:
	_web_socket_client.connected_to_server.connect(_on_web_socket_client_connected_to_server)
	_web_socket_client.connection_closed.connect(_on_web_socket_client_connection_closed)
	_web_socket_client.message_received.connect(_on_web_socket_client_message_received)
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

	# players
	_players.merge(message["players"]) # TODO: PackedByteArray なので merge できない

	# time
	var ping = Time.get_unix_time_from_system() - message["time"]
	_recent_ping_list.append(ping)
	if _recent_ping_list_max_size < _recent_ping_list.size():
		_recent_ping_list.pop_front()
	#print(_recent_ping_list)


func _on_connect_button_pressed():
	var _error = _web_socket_client.connect_to_url("%s:%s" % [ADDRESS, PORT])
	if _error == OK:
		print("[Client] connect_to_url OK")
	else:
		print("[Client] connect_to_url NG: %s" % error_string(_error))


# サーバーにデータを送信する
func _process_send(delta: float) -> void:
	if _web_socket_client.last_state != WebSocketPeer.STATE_OPEN:
		return
	_send_timer += delta
	if _send_timer < _send_interval:
		return
	_send_timer = 0.0

	var msg = {
		"position": _player.position,
	}
	_web_socket_client.send(msg)


# Ping の表示を更新する
func _process_refresh_ping(delta: float) -> void:
	if _recent_ping_list.size() == 0:
		return
	_ping_refresh_timer += delta
	if _ping_refresh_timer < _ping_refresh_interval:
		return
	_ping_refresh_timer = 0.0

	var ping_avg = _recent_ping_list.reduce(func(a, n): return a + n, 0.0) / _recent_ping_list.size()
	_ping_label.text = "Ping: %sms" % str(snappedf(_recent_ping_list[-1] * 1000, 0.01))
	_ping_avg_label.text = "(Avg: %sms)" % str(snappedf(ping_avg * 1000, 0.01))

	print(_players)
