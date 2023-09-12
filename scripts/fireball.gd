extends RigidBody3D
var dmg = 22

var father : int
# father path
var fpath : NodePath

@onready var explo = preload("res://scenes/explosion.tscn")
@onready var mod = get_node('modelo')

func _physics_process(delta):
	mod.get_active_material(0).uv1_offset = lerp( mod.get_active_material(0).uv1_offset,Vector3(2,2,2) * Time.get_ticks_msec()/3000,delta)

func _on_body_entered(hit):
	if hit.is_in_group('player'):
		if hit.player != father:
			if multiplayer.get_unique_id() == 1:
				hit._on_hit.rpc_id(hit.get_multiplayer_authority(),dmg)
				hit.hit_mark.rpc_id(father)
				get_parent()._explode(position)
				call_deferred('queue_free')

func _on_timer_timeout():
	get_parent()._explode(position)
	call_deferred('queue_free')
