class_name RingStation
extends SpaceObject



@export var ringRotationSpeed := 1.0
@onready var outerRing = $OuterRing
var isShip = true

var velocity = Vector3()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if visible:
		outerRing.rotation.x += ringRotationSpeed*delta
	

