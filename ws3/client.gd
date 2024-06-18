extends Node2D


const ADDRESS = "ws://localhost"
const PORT = 8080

@export var _web_socket_client: WebSocketClient

@export var _ping_refresh_interval: float = 0.25

# UI
@export var _connect_button: Button
@export var _ping_label: Label

var _server_unix_time: float = 0.0
var _ping_refresh_timer: float = 0.0


func _ready() -> void:
	_web_socket_client.connected_to_server.connect(_on_web_socket_client_connected_to_server)
	_web_socket_client.connection_closed.connect(_on_web_socket_client_connection_closed)
	_web_socket_client.message_received.connect(_on_web_socket_client_message_received)
	_connect_button.pressed.connect(_on_connect_button_pressed)


func _process(delta: float) -> void:
	# Ping
	if 0.0 < _server_unix_time:
		_ping_refresh_timer += delta
		if _ping_refresh_interval < _ping_refresh_timer:
			_ping_refresh_timer = 0.0
			var local_unix_time = Time.get_unix_time_from_system()
			var ping_ms = snappedf((local_unix_time -_server_unix_time) * 1000, 0.01)
			_ping_label.text = "Ping: %sms" % str(ping_ms)


func _on_web_socket_client_connected_to_server():
	print("[Client] Connected to server!")


func _on_web_socket_client_connection_closed():
	print("[Client] Connection closed.")


func _on_web_socket_client_message_received(message):
	#print("[Client] Message received from server. Message: %s" % [message])
	var msg = JSON.parse_string(message)
	_server_unix_time = msg["time"]


func _on_connect_button_pressed():
	var _error = _web_socket_client.connect_to_url("%s:%s" % [ADDRESS, PORT])
	if _error == OK:
		print("[Client] connect_to_url OK")
	else:
		print("[Client] connect_to_url NG: %s" % error_string(_error))
