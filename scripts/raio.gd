extends RayCast3D
var dmg := 25
var time := 0.0

@export var interpolation : Curve
@onready var mod = get_node('modelo')

var father : int
# father path
var fpath : NodePath

func _physics_process(delta):
	time += delta
	mod.get_active_material(0).uv1_offset += Vector3(0.2,0.2,0.2)
	scale = Vector3.ONE*interpolation.sample_baked(time*4.333)
	if is_colliding():
		var hit = get_collider()
		if hit.is_in_group('player'):
			if hit.player != father:
				if multiplayer.get_unique_id() == 1:
					hit._on_hit.rpc_id(hit.get_multiplayer_authority(),dmg)
					hit.hit_mark.rpc_id(father)
		enabled = false
	if time >= 0.1:
		enabled = false

func _on_timer_timeout():
	call_deferred('queue_free')
