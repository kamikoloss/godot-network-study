extends Node2D


const ADDRESS = "ws://localhost"
const PORT = 8080


@export var _web_socket_client: WebSocketClient
@export var _connect_button: Button


func _ready() -> void:
	_web_socket_client.connected_to_server.connect(_on_web_socket_client_connected_to_server)
	_web_socket_client.connection_closed.connect(_on_web_socket_client_connection_closed)
	_web_socket_client.message_received.connect(_on_web_socket_client_message_received)
	_connect_button.pressed.connect(_on_conect_button_pressed)


func _on_web_socket_client_connected_to_server():
	print("[Client] Connected to server!")


func _on_web_socket_client_connection_closed():
	print("[Client] Connection closed.")


func _on_web_socket_client_message_received(message):
	print("[Client] Message received from server. Message: %s" % [message])


func _on_conect_button_pressed():
	var _error = _web_socket_client.connect_to_url("%s:%s" % [ADDRESS, PORT])
	if _error == OK:
		print("[Client] connect_to_url OK")
	else:
		print("[Client] connect_to_url NG: %s" % error_string(_error))
