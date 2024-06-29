class_name StellarObject
extends SpaceObject


@export var mass: float
@export var orbitEccentricity = 0.0
@export var apoapsisVelocity: float
var orbitingBodies = []
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Radar Objects")
	for node in get_children():
		if node.get("mass") and node.mass > 0.0:
			var direction = node.global_position.direction_to(global_position).rotated(Vector3.LEFT,.5*PI)
			node.velocity += direction * sqrt(mass/position.distance_to(node.global_position))
			
			orbitingBodies.append(node)

var velocity = Vector3()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	for node in orbitingBodies:
		var direction = node.global_position.direction_to(global_position)
		
		var acceleration = mass/position.distance_squared_to(node.position)
		print("acceleration of "+ node.name+": "+str(acceleration))
		node.velocity += acceleration * direction * 60
		
		print(node.name + ": "+str(node.velocity))
	position += velocity * delta * .01
