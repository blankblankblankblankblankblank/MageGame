extends Area3D
var dmg = 5
var speed = 52
var impulse = 3

var father : int
# father path
var fpath : NodePath

@onready var mod = get_node('modelo')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position -= transform.basis.z * speed * delta

func _on_body_entered(hit):
	if hit.is_in_group('player'):
		if hit.player != father:
			hit._on_hit.rpc_id( hit.get_multiplayer_authority(), dmg)
#			hit.hit_mark.rpc_id(father)
			call_deferred('queue_free')
	else:
		call_deferred('queue_free')

func _on_timer_timeout():
	call_deferred('queue_free')
