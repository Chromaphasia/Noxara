extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	startingDist = $SubViewport/Scale.position.distance_to($SubViewport/Camera3D.position)
	print(str( -10200 % 10000))
var startingDist

var printTimer = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	printTimer += delta	
	$SubViewport2/Position.position.z += -delta
	var scaleModifier = 1.0
	var scaleDistanceModifier = .5
	$SubViewport/Scale.scale = Vector3.ONE * ($SubViewport/Scale.position.distance_to($SubViewport/Camera3D.position)/($SubViewport2/Position.position.distance_to($SubViewport2/Camera3D2.position)*scaleModifier))
	#print($SubViewport/Scale.scale)
	$SubViewport/Scale.position.z -= delta*scaleDistanceModifier
	var horizontalAxis = Input.get_axis("HorizontalDown","HorizontalUp")
	if horizontalAxis:
		$SubViewport/Camera3D.position.x += horizontalAxis*.01
		$SubViewport2/Camera3D2.position.x += horizontalAxis*.01
	#$SubViewport/Scale.position.z += -delta/4
	if printTimer > 2.0:
		printTimer = 0
		var leftPerceivedDistance = roundf($SubViewport2/Position.position.distance_to($SubViewport2/Camera3D2.position)/$SubViewport2/Position.scale.x)
		var rightPerceivedDistance = roundf($SubViewport/Scale.position.distance_to($SubViewport/Camera3D.position)/$SubViewport/Scale.scale.x)
		#print("Left Perceived Distance: " + str(leftPerceivedDistance))
		#print("Right Perceived Distance: " + str(rightPerceivedDistance))
		#print("Ratio: "+str(rightPerceivedDistance/leftPerceivedDistance))
		
