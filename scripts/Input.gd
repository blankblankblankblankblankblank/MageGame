extends MultiplayerSynchronizer

@export var jumping := false;
@export var direction := Vector2();
@export var cam_rot := Vector3();
@export var rot := Vector3();
var sense = 0.2;

@export var arma = 0

#the timers are numbered for the weaponds they represent
#0 - ray
#1 - fireball
@onready var rayt = get_node('0')
@onready var fibt = get_node('1')

@onready var timers = [get_node('0'),get_node('1'),get_node('2')]

func _ready():
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())
	set_process_input(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true

func _process(_delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("a", "d", "w", "s")
	if Input.is_action_just_pressed("ui_accept"):
		jump.rpc()
	if Input.is_action_just_pressed('MouseOne'):
		shoot.rpc()

@rpc('call_remote')
func shoot():
	if timers[arma].is_stopped():
		get_parent().get_parent().add_shot(get_parent().player,get_parent().get_path(),arma)
		timers[arma].start()

func _input(event):
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * sense))
		get_parent().get_node('Camera3D').rotate_x(deg_to_rad(-event.relative.y * sense))
		get_parent().get_node('Camera3D').rotation.x = clamp(get_parent().get_node('Camera3D').rotation.x, -PI/2, PI/2)
		cam_rot = get_parent().get_node('Camera3D').rotation
		rot = get_parent().rotation
	if event is InputEventKey:
		if int(OS.get_keycode_string(event.key_label)) != 0:
			print(OS.get_keycode_string(event.key_label))
			arma = int(OS.get_keycode_string(event.key_label))-1
