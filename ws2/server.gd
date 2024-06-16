extends Node


const PORT = 9090


var mp_peer := WebSocketMultiplayerPeer.new()


func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	var _error = mp_peer.create_server(PORT)
	if _error == OK:
		print("[Server] succeeded to listen on %s" % PORT)
	else:
		print("[Server] failed to listen on %s for %s" % [PORT, error_string(_error)])

	multiplayer.multiplayer_peer = mp_peer


func _on_peer_connected(id: int) -> void:
	print("[Server] peer (%s) connected." % str(id))


func _on_peer_disconnected(id: int) -> void:
	print("[Server] peer (%s) disconnected." % str(id))
