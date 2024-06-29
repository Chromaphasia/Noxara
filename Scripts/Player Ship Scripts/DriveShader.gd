extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready():
	mesh.surface_get_material(0).set_shader_parameter("cameraNormalVector",-position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
