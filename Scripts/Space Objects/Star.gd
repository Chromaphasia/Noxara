extends SpaceObject
class_name Star

@onready var light = $DirectionalLight3D

var player
func _ready():
	await get_tree().root.ready
	player = get_tree().get_first_node_in_group("Player")
	
	add_to_group("Relative Objects")
	add_to_group("Radar Objects")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	light.look_at(player.position)
