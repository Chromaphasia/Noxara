extends Node3D

@onready var player = get_tree().get_first_node_in_group("Player")
@export var galacticScale = 100000

# Called when the node enters the scene tree for the first time.
func _ready():
	for node in get_tree().get_nodes_in_group("Relative Objects"):
		node.localPosition = node.position - player.position
		updateGalacticOffset(node)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for node in get_tree().get_nodes_in_group("Relative Objects"):
		updateGalacticOffset(node)
		



var checkIncrement = 0
func updateGalacticOffset(node: SpaceObject):
	#if node.name == "Sun":
	#	return
	#print("Local: " + str(node.localPosition))
	#print(player.velocity)
	node.localPosition -= player.velocity
	var temp
	#if node.localPosition.x > galacticScale:
	#	node.localPosition.x -= galacticScale
#		node.galacticPosition.x += 1
#	elif node.localPosition.x < -galacticScale:
#		node.localPosition.x += galacticScale
#		node.galacticPosition.x -= 1
#	if node.localPosition.y > galacticScale:
#		node.localPosition.y -= galacticScale
#		node.galacticPosition.y += 1
#	elif node.localPosition.y < -galacticScale:
#		node.localPosition.y += galacticScale
#		node.galacticPosition.y -= 1
#	if node.localPosition.z > galacticScale:
#		node.localPosition.z -= galacticScale
#		node.galacticPosition.z += 1
#	elif node.localPosition.z < -galacticScale:
#		node.localPosition.z += galacticScale
#		node.galacticPosition.z -= 1
	if node.localPosition.x >= galacticScale:
		temp = node.localPosition.x - floor(node.localPosition.x/galacticScale)*galacticScale
		node.galacticPosition.x += floor(node.localPosition.x/galacticScale)
		node.localPosition.x = temp
	elif node.localPosition.x < 0:
		temp = node.localPosition.x - (ceil(node.localPosition.x/galacticScale)*galacticScale)+galacticScale
		node.galacticPosition.x += ceil(node.localPosition.x/galacticScale)-1
		node.localPosition.x = temp
	if node.localPosition.y >= galacticScale:
		temp = node.localPosition.y - floor(node.localPosition.y/galacticScale)*galacticScale
		node.galacticPosition.y += floor(node.localPosition.y/galacticScale)
		node.localPosition.y = temp
	elif node.localPosition.y < 0:
		temp = node.localPosition.y - (ceil(node.localPosition.y/galacticScale)*galacticScale)+galacticScale
		node.galacticPosition.y += ceil(node.localPosition.y/galacticScale)-1
		node.localPosition.y = temp
	if node.localPosition.z >= galacticScale:
		temp = node.localPosition.z - floor(node.localPosition.z/galacticScale)*galacticScale
		node.galacticPosition.z += floor(node.localPosition.z/galacticScale)
		node.localPosition.z = temp
	elif node.localPosition.z < 0:
		temp = node.localPosition.z - (ceil(node.localPosition.z/galacticScale)*galacticScale)+galacticScale
		node.galacticPosition.z += ceil(node.localPosition.z/galacticScale)-1
		node.localPosition.z = temp
	#print(node.galacticPosition)
	
	node.position = node.localPosition + (node.galacticPosition*galacticScale)
	#node.scaleFactor = -1/(node.localPosition.z+galacticScale*node.galacticPosition.z)
	#print(node.scaleFactor)
	checkIncrement += 1
	if abs(node.galacticPosition.x) > 1 or abs(node.galacticPosition.y) > 1 or abs(node.galacticPosition.z) > 1 :#and (node.visible or checkIncrement == 60):
		if checkIncrement == 61:
			checkIncrement = 0
		#print("Galactic: "+str(node.galacticPosition))
		#print("Local: " +str(node.localPosition))
		#print("Actual: " +str(node.position))
		#var fakePosition = Vector3(node.galacticPosition.x*galacticScale,node.galacticPosition.y*galacticScale,node.galacticPosition.z*galacticScale)
		#if node.galacticPosition.length() < 300:
		#	fakePosition += node.localPosition
		var fakePosition = Vector3(node.localPosition.x+node.galacticPosition.x*galacticScale,node.localPosition.y+node.galacticPosition.y*galacticScale,node.localPosition.z+node.galacticPosition.z*galacticScale)
		var fakeDistance = fakePosition.length()#-(node.trueDiameter/2)
		if node.name != "Sun":
			print("Local: "+ str(node.localPosition))
			print("Galactic: "+ str(node.galacticPosition))
			print("Total: " + str(fakePosition))
		#print(node.name+" Distance: "+str(fakeDistance))#-(node.trueDiameter/2)))
		node.position = fakePosition.normalized()*(galacticScale+(node.galacticPosition.length()*(1/galacticScale)))
		var newScaleFactor = node.position.distance_to(player.position)/fakeDistance#*(.05*node.galacticPosition.length()))
		#print(node.name+" Actual Distance: "+str(node.position.distance_to(player.position)))
		#print(node.name+" Scale Factor: "+str(newScaleFactor))
		#if newScaleFactor == INF:
		#	newScaleFactor = 1
		node.scaleFactor = newScaleFactor
		
