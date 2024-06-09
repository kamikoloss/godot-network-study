extends CharacterBody2D


const MOVE_SPEED = 400.0 # 左右の移動速度
const JUMP_SPEED = -800.0 # ジャンプの速度
const GRAVITY = 2000.0 # 落下速度


@export var _is_debug = false


var sync_position = Vector2.ZERO # 同期用の座標


func _physics_process(delta: float) -> void:
	# Debug
	if _is_debug:
		_move(delta)
		return

	# 自身が Local Peer かどうか
	# https://docs.godotengine.org/ja/4.x/classes/class_multiplayerapi.html#class-multiplayerapi-method-get-unique-id
	var _is_local_authority = name == str(multiplayer.get_unique_id())

	# 自身が Local Peer の場合
	if _is_local_authority:
		# 入力に応じて移動する
		_move(delta)
		# Server に情報を送信する
		# https://docs.godotengine.org/ja/4.x/classes/class_node.html#class-node-method-rpc-id
		push_to_server.rpc_id(1, position)
	# 自身が Remote Peer の場合: 座標を同期する
	else:
		position = sync_position


func _move(delta: float) -> void:
	# 地面に接している場合
	if is_on_floor():
		# ui_accept を押したとき: ジャンプする
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = JUMP_SPEED
	# 地面に接していない場合: 自由落下する
	else:
		velocity.y += GRAVITY * delta

	# ui_left/ui_right を押しているとき: 左右に移動する
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * MOVE_SPEED
	else:
		velocity.x = 0

	move_and_slide()


# mode = "any_peer": Server/Client 両方から呼び出されることがある
# sync = "call_remote": Local Peer では呼び出されない
# transfer_mode = "unreliable_ordered"
# https://docs.godotengine.org/ja/4.x/tutorials/networking/high_level_multiplayer.html#remote-procedure-calls
@rpc("any_peer", "call_remote", "unreliable_ordered")
func push_to_server(new_position: Vector2) -> void:
	# オンライン状態 かつ 別次元の自分から呼び出された場合: 同期用の座標を更新する
	if multiplayer.is_server() and name == str(multiplayer.get_remote_sender_id()):
		sync_position = new_position
