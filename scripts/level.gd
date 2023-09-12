extends Node3D

const SPAWN_RANDOM := 5.0

# raio = 0
const shots = [preload('res://scenes/raio.tscn'),preload('res://scenes/fireball.tscn'),preload('res://scenes/ice_knife.tscn')]
const explo = preload('res://scenes/explosion.tscn')
@export var spawn_positions := []

var rng = RandomNumberGenerator.new()

func _ready():
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)
	

func _exit_tree():
	if not multiplayer.is_server(): 
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	var character = preload("res://scenes/player.tscn").instantiate()
	# Set player id.
	character.player = id
	# Randomize character position.
	character.position = get_node(spawn_positions.pick_random()).global_position
	character.name = str(id)
	add_child(character, true)

func del_player(id: int):
	var player = get_node_or_null(str(id))
	if player != null:
		get_node(str(id)).queue_free()

@rpc('call_local')
func add_shot(id:int,parent_way:NodePath,shot:int):
	match shot:
		0:
			var r = shots[shot].instantiate()
			r.name = str(randi_range(0, 1024))
			r.father = id
			r.fpath = parent_way
			#r.get_node('modelo').position = get_parent().get_node('Marker3D').position - get_parent().get_node('Camera3D').position + Vector3(0,0,-250)
			r.position = get_node(parent_way).get_node('Camera3D/Marker3D').global_position
			r.rotation = get_node(parent_way).get_node('Camera3D').global_rotation
			add_child(r,true)
		1:
			var r = shots[shot].instantiate()
			r.name = str(randi_range(0, 1024))
			r.father = id
			r.fpath = parent_way
			#r.get_node('modelo').position = get_parent().get_node('Marker3D').position - get_parent().get_node('Camera3D').position + Vector3(0,0,-250)
			r.position = get_node(parent_way).get_node('Camera3D/Marker3D2').global_position
			r.rotation = get_node(parent_way).get_node('Camera3D').global_rotation
			add_child(r,true)
			r.apply_central_impulse(-(get_node(parent_way).get_node('Camera3D').global_transform.basis.z) * 60)
		2:
			for i in 9:
				var r = shots[shot].instantiate()
				r.name = str(randi_range(0, 3072))
				r.father = id
				r.fpath = parent_way
				r.position = get_node(parent_way).get_node('Camera3D/Marker3D').global_position
				rng.randomize()
				var cam = get_node(parent_way).get_node('Camera3D')
				r.rotation = cam.global_rotation + Vector3(rng.randf_range(-0.1,0.1),rng.randf_range(-0.09,0.11),rng.randf_range(-0.1,0.09))*0.3
				add_child(r,true)

func _explode(pos:Vector3):
	var r = explo.instantiate()
	r.position = pos
	add_child(r,true)
