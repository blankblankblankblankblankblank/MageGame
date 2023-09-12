extends CharacterBody3D


#vars
const JUMP_VELOCITY = 12.0
var MAX_VEL = 18.0
var accel := 24.0
var friction := 3.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

#stats
@export var hp = 200

#ui
@onready var progress = $Control/ProgressBar
@onready var label = $Control/ProgressBar/Label
@onready var speedl = $Control/speed
@onready var cam = $Camera3D

# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)

# Player synchronized input.
@onready var input = $PlayerInput

func _ready():
	# Set the camera as current if we are this player.
	if player == multiplayer.get_unique_id():
		cam.current = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		cam.visible = true
		$Control.show()
	# Only process on server.
	# EDIT: Let the client simulate player movement too to compesate network input latency.
	# set_physics_process(multiplayer.is_server())

@rpc ("call_remote","any_peer")
func rotate_rpc(camr:Vector3,rot:Vector3,path:NodePath):
	if player != multiplayer.get_unique_id():
#		get_node(path).cam.rotation = camr
#		get_node(path).rotation = rot
		get_node(path).cam.rotation.x = lerp_angle(get_node(path).cam.rotation.x,camr.x,0.7	)
		get_node(path).rotation.y = lerp_angle(get_node(path).rotation.y,rot.y,0.7)

@rpc("call_local",'any_peer')
func hit_mark():
	$Camera3D/HitTimer.start()
	$Camera3D/HitMark.visible = true

func _on_hit_timer_timeout():
	$Camera3D/HitMark.visible = false

func _physics_process(delta):
	rotate_rpc.rpc(cam.rotation,rotation,get_path())
	var direction = transform.basis * (Vector3(input.direction.x, 0, input.direction.y)).normalized()
	if direction:
		velocity = _accelerate(accel,direction,delta)
	
	MAX_VEL = 18.0
	if not is_on_floor():
		MAX_VEL = 12.0
		velocity.y -= gravity * delta
	else:
		velocity = _friction(delta)
	if input.jumping and is_on_floor():
		velocity.y = JUMP_VELOCITY
	input.jumping = false
	
	move_and_slide()
	speedl.text = str(snapped(Vector3(velocity.x,0,velocity.z).length(),0.01))
	

func _accelerate(accele : float, dir : Vector3, delta : float) -> Vector3:
	var current_speed: float = velocity.dot(dir.normalized())
	var add_speed: float = clamp(MAX_VEL - current_speed, 0, accele * 5 * delta)
	return velocity + (dir * add_speed)


func _friction(delta: float) -> Vector3:
	var speed: float = velocity.length()
	var scaled_velocity: Vector3
	if speed != 0:
		var drop = speed * friction * delta
		scaled_velocity = velocity * max(speed - drop, 0) / speed
	if speed < 2:
		return velocity * 0.1
	if (transform.basis * Vector3(input.direction.x, 0, input.direction.y)).normalized() == Vector3.ZERO:
		return velocity * 0.888
	return scaled_velocity

@rpc("any_peer",'call_local')
func _on_hit(dmg : int):
	hp -= dmg
	if hp <= 0:
		var pos := Vector2.from_angle(randf() * 2 * PI)
		position = Vector3(pos.x * 5 * randf(), 0, pos.y * 5 * randf())
		hp = 200
	_friction(0.016)
	update_ui()

func update_ui():
	progress.value = hp
	label.text = str(hp)

func _on_server_synchronizer_synchronized():
	update_ui()
