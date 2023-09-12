extends AnimatableBody3D
var dmg = 18
@onready var anim1 = get_node('AnimationPlayer')

func _ready():
#	parti.emitting = true
	anim1.play('pop')

func _physics_process(delta):
	position.move_toward(position+Vector3(0,0,-1),1)
