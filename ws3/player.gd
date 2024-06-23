extends CharacterBody2D
class_name Player


const SPEED = 400.0
const JUMP_VELOCITY = -800.0


var gravity = 3200
var is_local = true


func _ready() -> void:
	# ローカルで動かしている Player でない場合: 操作および物理を無効にする
	if not is_local:
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
