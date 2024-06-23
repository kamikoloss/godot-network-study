extends CharacterBody2D
class_name Player


const SPEED = 400.0
const JUMP_VELOCITY = -1600.0


var gravity = 4800
var is_other = false


func _ready() -> void:
	# 他プレイヤーの場合: 操作および物理を無効にする
	if is_other:
		set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
