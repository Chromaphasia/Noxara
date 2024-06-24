class_name PlayerShip
extends CharacterBody3D


@export var manueverability := .001
@export var maxSpeed := 2.0
@export var acceleration := .02
@export var radarRefreshSpeed = 5.0
@export var radarRange = 2000
var flightMode: bool
var dampeners: bool
var safeMode: bool
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const horizontalThrustRatio = .5
const verticalThrustRatio = .7


func _ready():
	#Fixes debug message spam from look_at function
	velocity.z -= .00001
	#Sets the mouse to be hidden.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	flightMode = true
	dampeners = true
	safeMode = true
	initializeShip()

#Downstream Variables
var maxPitchVelocity: float
var maxYawVelocity: float
var maxRollVelocity: float
var maxRotationalVelocity: Vector3
#Sets downstream variables based on ship stats
func initializeShip():
	maxPitchVelocity = manueverability*30
	maxYawVelocity = maxPitchVelocity/3
	maxRollVelocity = maxPitchVelocity*2.5
	maxRotationalVelocity = Vector3(maxPitchVelocity,maxYawVelocity,maxRollVelocity)	
@onready var radarIcon = preload("res://Scenes/Instanced Scenes/Space Objects/Ships/Ship Internals/radar_icon.tscn")
var pingsSinceLastCheck = 5
var objectsInRange = []
func radarPing():
	pingsSinceLastCheck += 1
	#print("ping")
	if pingsSinceLastCheck >= 5:
		pingsSinceLastCheck = 0
		for node in get_tree().get_nodes_in_group("Radar Objects"):
			print(node.name)
			if not node in objectsInRange and node.position.distance_to(position) < radarRange:
				print("Appending: "+node.name)
				objectsInRange.append(node)
	for node in $SubViewport/HBoxContainer/PanelContainer/RadarSprite.get_children():
		if node.name != "Spinner":
			node.queue_free()
	for node in objectsInRange:
		if node.position.distance_to(position) > radarRange:
			objectsInRange.erase(node)
		else:
			var radarIconNode = radarIcon.instantiate()
			if node.get('isShip'):
				if !node.get('isHostile'):
					radarIconNode.frame = 0
				else:
					radarIconNode.frame = 1
			else:
				radarIconNode.frame = 2
			radarIconNode.radarRange = radarRange
			var relativePosition = node.position-position
			#print(node.name+" Relative Position: "+str(relativePosition))
			var tempQuat = Quaternion(relativePosition.x,relativePosition.y,relativePosition.z,0)
			var rotatedQuat = quaternion.inverse() * tempQuat * quaternion
			#print("Rotated Position: "+ str(rotatedQuat))
			radarIconNode.relativePosition = Vector3(rotatedQuat.x,rotatedQuat.y,rotatedQuat.z)
			radarIconNode.initIcon()
			$SubViewport/HBoxContainer/PanelContainer/RadarSprite.add_child(radarIconNode)
	var pingTween = get_tree().create_tween()
	pingTween.tween_callback($SubViewport/HBoxContainer/PanelContainer/RadarSprite.play.bind("default"))
	pingTween.tween_property($SubViewport/HBoxContainer/PanelContainer/RadarSprite/Spinner,"rotation",TAU-.001,2.6)
	pingTween.tween_property($SubViewport/HBoxContainer/PanelContainer/RadarSprite/Spinner,"rotation",0,0.01) 
	#pingTween.tween_property($SubViewport/HBoxContainer/PanelContainer/RadarSprite,"frame",0,0.01)
	#pingTween.tween_callback($SubViewport/HBoxContainer/PanelContainer/RadarSprite.stop)

var currentTarget
var radarTimer = 0
func _process(delta):
	#print(currentTarget)
	#print($SubViewport/HBoxContainer/PanelContainer/RadarSprite/Spinner.rotation)
	radarTimer -= delta
	if radarTimer <= 0:
		radarTimer = radarRefreshSpeed
		radarPing()
	var firstGimbal = $"Gimbal/First Gimbal"
	var secondGimbal = $"Gimbal/First Gimbal/Second Gimbal"
	if !currentTarget:
		if floor(velocity.length()*100) != 0: 
			firstGimbal.rotation.x = move_toward(firstGimbal.rotation.x,$Arrow.rotation.y,abs(firstGimbal.rotation.x - $Arrow.rotation.y)*.5)
			secondGimbal.rotation.x = move_toward(secondGimbal.rotation.x,-$Arrow.rotation.x,abs(secondGimbal.rotation.x+$Arrow.rotation.x)*.5)
			#firstGimbal.rotation.x = $Arrow.rotation.y
			#secondGimbal.rotation.x = -$Arrow.rotation.x
		#$"Gimbal/First Gimbal/Second Gimbal/Third Gimbal".rotation.x = $Arrow.rotation.z
		else:
			firstGimbal.rotation.x = move_toward(firstGimbal.rotation.x, 0, abs(firstGimbal.rotation.x*.5))
			secondGimbal.rotation.x = move_toward(secondGimbal.rotation.x, 0, abs(secondGimbal.rotation.x*.5))
	else:
		$hiddenTargeter.look_at(currentTarget.position)
		firstGimbal.rotation.x = move_toward(firstGimbal.rotation.x, $hiddenTargeter.rotation.y,abs(firstGimbal.rotation.x-$hiddenTargeter.rotation.y)*.5)
		secondGimbal.rotation.x = move_toward(secondGimbal.rotation.x, -$hiddenTargeter.rotation.x,abs(secondGimbal.rotation.x+$hiddenTargeter.rotation.x)*.5)
		
	if Input.is_action_just_pressed("Target"):
		var previousTarget = currentTarget
		for node in objectsInRange:
			var trueRotation = position.direction_to(node.position)
			var shipRotationDirection = -transform.basis.z
			print("Basis: "+ str(transform.basis))
			print(node.name+": " + str(shipRotationDirection.angle_to(trueRotation)))
			
			if abs(shipRotationDirection.angle_to(trueRotation)) < .2*PI:
				if not currentTarget:
					currentTarget = node
				elif abs(shipRotationDirection.angle_to(trueRotation)) < abs(shipRotationDirection.angle_to(position.direction_to(currentTarget.position))):
					currentTarget = node
		
		if currentTarget == previousTarget:
			currentTarget = null
var throttleAmount := 0.0
const throttleRateOfChange = .01
var rotationalVelocity := Vector3()
var printTimer = 0.0

func _physics_process(delta):
	#Establishes rotated velocity
	var tempQuat = Quaternion(velocity.x,velocity.y,velocity.z,0)
	tempQuat = quaternion.inverse()*tempQuat*quaternion
	var rotatedVelocity = Vector3(tempQuat.x,tempQuat.y,tempQuat.z)
	#print("Rotated Velocity: "+ str(rotatedVelocity))
	tempQuat = null
	printTimer += delta
	#Const for converting between the pixels of mouse movement into radians. This is converting from a rather large number to a very small one.
	const mouseVelocityAdjustment = .01
	#Vector defining the maximum velocity the player can impart with the mouse. This can't just be (1,1) since mouse movements don't really fire every frame? Its weird, but (8,8) seems to give a limit that matches full joystick/analog rotation.
	const maximumMouseVelocity = Vector2(8,8)
	#Initializes the variables here for dampening
	var mouseVelocity = Vector2(0,0)
	var pitchRollVector = Vector2(0,0)
	var yawAxis = 0.0
	#ROTATION
	#Check to prevent movement while in a menu.
	if flightMode:
		mouseVelocity = Input.get_last_mouse_velocity()*mouseVelocityAdjustment*Options.flyingMouseSensitivity
		mouseVelocity = mouseVelocity.clamp(-maximumMouseVelocity,maximumMouseVelocity)
		if mouseVelocity != Vector2(0,0):
			#print(mouseVelocity)
			#Pitch and Roll for Mouse
			rotationalVelocity.x -= mouseVelocity.y*manueverability
			rotationalVelocity.z += mouseVelocity.x*manueverability
			#print(rotationalVelocity)
		#Pitch and Roll for bindings
		pitchRollVector = Input.get_vector("PitchDown","PitchUp","RollDown","RollUp")
		yawAxis = Input.get_axis("YawDown","YawUp")
		if pitchRollVector != Vector2() or yawAxis != 0:
			rotationalVelocity.x -= pitchRollVector.x*manueverability
			#print("controller: " +str(pitchRollVector))
			rotationalVelocity.z += pitchRollVector.y*manueverability
			#print(rotationalVelocity)
			#Yaw for bindings:
			rotationalVelocity.y -= yawAxis*manueverability
		#Clamps
		if safeMode:
			rotationalVelocity = rotationalVelocity.clamp(-maxRotationalVelocity,maxRotationalVelocity)
		#RotationHandling
		#print("After Application: " + str(rotationalVelocity))
	quaternion = quaternion * Quaternion(Vector3.BACK,rotationalVelocity.z)
	quaternion = quaternion * Quaternion(Vector3.RIGHT,rotationalVelocity.x)
	quaternion = quaternion * Quaternion(Vector3.UP,rotationalVelocity.y)
	#rotation.z += rotationalVelocity.z
	#rotation.x += rotationalVelocity.rotated(Vector3(0,0,1),rotation.z).x
	#rotation.y += rotationalVelocity.rotated(Vector3(0,0,1),rotation.z).y
	if dampeners:
		#print("PitchRollVector: " +str(pitchRollVector))
		if pitchRollVector.y == 0 and rotationalVelocity.z != 0:
			rotationalVelocity.z = move_toward(rotationalVelocity.z, 0, manueverability)
		if pitchRollVector.x == 0 and rotationalVelocity.x != 0:
			#print("Slowing Pitch")
			rotationalVelocity.x = move_toward(rotationalVelocity.x, 0, manueverability)
		if yawAxis == 0 and rotationalVelocity.y != 0:
			rotationalVelocity.y = move_toward(rotationalVelocity.y,0,manueverability)
			
	#THRUST
	#Velocity for this frame. This keeps free floating velocity consistent between frames.
	var frameVelocity = Vector3()
	if flightMode:
		#Forward throttle is set-and-forget, so throttle amount is a number 
		var throttleAxis = Input.get_axis("ThrottleDown","ThrottleUp")
		throttleAmount += throttleAxis*throttleRateOfChange
		
		var trueThrottleAxis = Input.get_axis("TrueThrottleNeg","TrueThrottlePos")
		if trueThrottleAxis != 0:
			throttleAmount = trueThrottleAxis
		#Throttle Deadzone
		if -.02 < throttleAmount and throttleAmount < .02 and throttleAxis == 0:
			throttleAmount = 0.0
		#Limiter
		throttleAmount = clamp(throttleAmount,-1.0,1.0)
		
		#Local Velocity Value
		
		#Apply Throttle to Velocity
		if not safeMode:
			frameVelocity.z += throttleAmount*acceleration
		else:
			var localVelocityAngle = $Arrow.rotation
			#print("Rotated Velocity Z: " + str(-rotatedVelocity.z*GlobalFunctions.roundAway(throttleAmount)) + "<"+str(maxSpeed*throttleAmount))
			if -rotatedVelocity.z*sign(throttleAmount) < maxSpeed*abs(throttleAmount):
				if !(-rotatedVelocity.z*sign(throttleAmount) > 0 and velocity.length() > maxSpeed*1.25): 
					frameVelocity.z = -move_toward(frameVelocity.z, maxSpeed*throttleAmount,acceleration)
			
		#Horizontal and vertical thrust
		var horizontalThrustVector = Input.get_axis("HorizontalDown","HorizontalUp")
		print("Rotated Velocity X: "+str(rotatedVelocity.x)+"<"+str(maxSpeed*horizontalThrustVector))
		if rotatedVelocity.x*GlobalFunctions.roundAway(horizontalThrustVector) < maxSpeed:
			if !(-rotatedVelocity.x*sign(throttleAmount) > 0 and velocity.length() > maxSpeed*1.25): 
				frameVelocity.x += horizontalThrustVector*acceleration*horizontalThrustRatio
		var verticalThrustVector = Input.get_axis("VerticalDown","VerticalUp")
		if rotatedVelocity.y*GlobalFunctions.roundAway(verticalThrustVector) < maxSpeed:
			if !(-rotatedVelocity.y*sign(throttleAmount) > 0 and velocity.length() > maxSpeed*1.25): 
				frameVelocity.y += verticalThrustVector*acceleration*verticalThrustRatio
		#Velocity Pointer Arrow
		
		$Arrow.look_at($Arrow.global_transform.origin + velocity*20,Vector3(.7,.3,0).normalized())
		
		#Dampening
		
		if dampeners and floor(velocity.length()*100) != 0:
			var localVelocityAngle = $Arrow.rotation 
			printTimer = 0
			#print($Arrow.rotation)
			#print("Frame Velocity Z :"+str(frameVelocity.z))
			if rotatedVelocity.z > 0 and frameVelocity.z == 0:
			#if ((1.1*PI >= localVelocityAngle.y and localVelocityAngle.y >.5*PI) or (-1.1*PI <= localVelocityAngle.y and localVelocityAngle.y <-0.5*PI)) and frameVelocity.z == 0:
				#print("Moving Forwards: "+ str(2000.0*(.5 - abs((localVelocityAngle.y/PI)-1.0)) * acceleration))
				frameVelocity.z -= 2.0*(.5 - abs((abs(localVelocityAngle.y)/PI)-1.0)) * acceleration
			elif rotatedVelocity.z < 0 and frameVelocity.z == 0:
			#elif localVelocityAngle.y < .5 * PI and localVelocityAngle.y > -.5* PI and frameVelocity.z == 0:
				#print("Moving Backwards: " + str(2000.0*(.5 - abs((localVelocityAngle.y/PI))) * acceleration))
				frameVelocity.z += 2.0*(.5 - abs((localVelocityAngle.y/PI))) * acceleration
			if rotatedVelocity.x > 0 and frameVelocity.x == 0:
			#if localVelocityAngle.y > 0 and localVelocityAngle.y < PI and frameVelocity.x == 0:
				print("Moving Right: "+ str(2000.0*(.5 - abs((localVelocityAngle.y/PI)-.5)) * acceleration*.3))
				frameVelocity.x += 2.0*(.5 - abs((localVelocityAngle.y/PI)-.5)) * acceleration*horizontalThrustRatio
			elif rotatedVelocity.x < 0 and frameVelocity.x == 0:
			#elif localVelocityAngle.y < 0 and localVelocityAngle.y > -1.0*PI and frameVelocity.x == 0:
				print("Moving Left: "+ str(2000.0*(.5 - abs((localVelocityAngle.y/PI)+.5)) * acceleration*.3))
				frameVelocity.x -= 2.0*(.5 - abs((localVelocityAngle.y/PI)+.5)) * acceleration*horizontalThrustRatio
			if rotatedVelocity.y > 0 and frameVelocity.y == 0:
			#if localVelocityAngle.x > 0 and localVelocityAngle.x < PI and frameVelocity.y == 0:
				print("Moving Down: "+ str(2000.0*(.5 - abs((localVelocityAngle.x/PI)-.5)) * acceleration*.5))
				frameVelocity.y -= 2.0*(.5 - abs((localVelocityAngle.x/PI)-.5)) * acceleration*verticalThrustRatio
			elif rotatedVelocity.y < 0 and frameVelocity.y == 0:
			#elif localVelocityAngle.x < 0 and localVelocityAngle.x > -1.0*PI and frameVelocity.y == 0:
				print("Moving Up: "+ str(2000.0*(.5 - abs((localVelocityAngle.x/PI)+.5)) * acceleration*.5))
				frameVelocity.y += 2.0*(.5 - abs((localVelocityAngle.x/PI)+.5)) * acceleration*verticalThrustRatio
		#Rotates frame velocity to universal frame of reference
		#This rotation vector breaks everything:
		#(-0.724, 1.26, -1.29)
		
		#frameVelocity = frameVelocity.rotated(Vector3(0,1,0),rotation.y).rotated(Vector3(1,0,0).rotated(Vector3(0,1,0),rotation.y),rotation.x).rotated(Vector3(0,0,1).rotated(Vector3(1,0,0).rotated(Vector3(0,1,0),rotation.y),rotation.x),rotation.z)
		var frameVelocityQuaternion = Quaternion(frameVelocity.x,frameVelocity.y,frameVelocity.z,0)
		frameVelocityQuaternion = quaternion * frameVelocityQuaternion * quaternion.inverse()
		frameVelocity = Vector3(frameVelocityQuaternion.x,frameVelocityQuaternion.y,frameVelocityQuaternion.z)
		#Applies frame velocity to velocity
		velocity += frameVelocity
		#velocity = velocity.limit_length(maxSpeed)
		#Apply velocity to position
		position += velocity
	
	#Update UI on Console
	var speed = floor(velocity.length()*100)
	
	$SubViewport/HBoxContainer/Label.text = "Speed: "+str(floor(speed))+"\nThrottle: "+str(floor(throttleAmount*100))+"%"
