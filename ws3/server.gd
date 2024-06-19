extends Node


const PORT = 8080


@export var _web_socket_server: WebSocketServer

@export var _send_interval: float = 0.05


var _send_timer: float = 0.0
# 接続しているプレイヤーの情報
# { <PeerID>: { "position": <Vector2> } }
var _players: Dictionary = {}


func _ready() -> void:
	_web_socket_server.client_connected.connect(_on_web_socket_server_client_connected)
	_web_socket_server.client_disconnected.connect(_on_web_socket_server_client_disconnected)
	_web_socket_server.message_received.connect(_on_web_socket_server_message_received)

	_start_server()


func _process(delta: float) -> void:
	_process_send(delta)


func _on_web_socket_server_client_connected(peer_id: int):
	print("[Server] New peer connected. ID: ", peer_id)


func _on_web_socket_server_client_disconnected(peer_id: int):
	print("[Server] Peer disconnected. ID: ", peer_id)


func _on_web_socket_server_message_received(peer_id: int , message: Variant):
	#print("[Server] Message received from client. ID: %d, Message: %s" % [peer_id, message])
	var player_data = { peer_id: message }
	_players.merge(player_data)


func _start_server() -> void:
	var _error = _web_socket_server.listen(PORT)
	if _error == OK:
		print("[Server] listen OK")
	else:
		print("[Server] listen NG: %s" % error_string(_error))


# クライアントにデータを送信する
func _process_send(delta: float) -> void:
	_send_timer += delta
	if _send_timer < _send_interval:
		return
	_send_timer = 0.0

	for id in _web_socket_server.peers:
		var message = {
			"time": Time.get_unix_time_from_system(),
			"players": var_to_bytes(_players)
		}
		_web_socket_server.send(id, message)
