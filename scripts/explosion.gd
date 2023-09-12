extends Area3D
var dmg = 18
var impulse = 45

@onready var coli = get_node('CollisionShape3D')
@onready var mod1 = get_node('MeshInstance3D')
@onready var mod2 = get_node('MeshInstance3D2')
@onready var parti = get_node('GPUParticles3D')
@onready var anim = get_node('AnimationPlayer')

func _ready():
	parti.emitting = true
	anim.play('explosion')
	mod1.get_active_material(0).albedo_color.a = 1.1
	mod2.get_active_material(0).albedo_color.a = 1.138

func _physics_process(delta):
	mod1.get_active_material(0).uv1_offset = lerp( mod1.get_active_material(0).uv1_offset,Vector3.ONE * Time.get_ticks_msec()/(3000/mod1.scale.x),delta)
	mod2.get_active_material(0).uv1_offset = lerp( mod2.get_active_material(0).uv1_offset,Vector3(2,2,2) * Time.get_ticks_msec()/3000,delta)
	mod1.get_active_material(0).albedo_color.a -= 0.022
	mod2.get_active_material(0).albedo_color.a -= 0.023

func _on_timer_timeout():
	call_deferred('queue_free')

func _on_body_entered(hit):
	if hit.is_in_group('player'):
		var dist = position.distance_to(hit.position)
		var dir = position.direction_to(hit.position)
		if multiplayer.get_unique_id() == 1:
			hit.velocity = dir * impulse
			hit._accelerate(impulse,dir,1)
			hit._on_hit.rpc_id( hit.get_multiplayer_authority(), max( dmg - dist*3 ,0) )

func _on_animation_player_animation_finished(_anim_name):
	coli.disabled = true
