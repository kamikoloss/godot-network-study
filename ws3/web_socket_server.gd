class_name WebSocketServer
extends Node


signal client_connected(peer_id: int)
signal client_disconnected(peer_id: int)
signal message_received(peer_id: int, message: String)


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass
