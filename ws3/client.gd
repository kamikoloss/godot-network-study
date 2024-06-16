extends Node2D


@export var _connect_button: Button


func _ready() -> void:
	_connect_button.pressed.connect(_on_conect_button_pressed)


func _on_conect_button_pressed():
	pass
