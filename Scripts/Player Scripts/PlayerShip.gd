extends CharacterBody3D


@export var manueverability := .001
@export var maxSpeed := .5
@export var acceleration := .02
var flightMode: bool
var dampeners: bool
var safeMode: bool
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
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

var throttleAmount := 0.0
const throttleRateOfChange = .01
var rotationalVelocity := Vector3()
func _physics_process(delta):
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
			print(mouseVelocity)
			#Pitch and Roll for Mouse
			rotationalVelocity.x -= mouseVelocity.y*manueverability
			rotationalVelocity.z += mouseVelocity.x*manueverability
			print(rotationalVelocity)
		#Pitch and Roll for bindings
		pitchRollVector = Input.get_vector("PitchDown","PitchUp","RollDown","RollUp")
		yawAxis = Input.get_axis("YawDown","YawUp")
		if pitchRollVector != Vector2() or yawAxis != 0:
			rotationalVelocity.x -= pitchRollVector.x*manueverability
			print("controller: " +str(pitchRollVector))
			rotationalVelocity.z += pitchRollVector.y*manueverability
			print(rotationalVelocity)
			#Yaw for bindings:
			rotationalVelocity.y -= yawAxis*manueverability
		#Clamps
		if safeMode:
			rotationalVelocity = rotationalVelocity.clamp(-maxRotationalVelocity,maxRotationalVelocity)
		#RotationHandling
		#print("After Application: " + str(rotationalVelocity))
	rotation.z += rotationalVelocity.z
	rotation.x += rotationalVelocity.rotated(Vector3(0,0,1),rotation.z).x
	rotation.y += rotationalVelocity.rotated(Vector3(0,0,1),rotation.z).y
	if dampeners:
		print("PitchRollVector: " +str(pitchRollVector))
		if pitchRollVector.y == 0 and rotationalVelocity.z != 0:
			rotationalVelocity.z = move_toward(rotationalVelocity.z, 0, manueverability)
		if pitchRollVector.x == 0 and rotationalVelocity.x != 0:
			print("Slowing Pitch")
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
		
		#Apply Throttle to Velocity
		if not safeMode:
			frameVelocity.z += throttleAmount*acceleration
		else:
			frameVelocity.z = -move_toward(frameVelocity.z, maxSpeed*throttleAmount,acceleration)
		#Horizontal and vertical thrust
		var horizontalThrustVector = Input.get_axis("HorizontalDown","HorizontalUp")
		frameVelocity.x += horizontalThrustVector*acceleration*.3
		var verticalThrustVector = Input.get_axis("VerticalDown","VerticalUp")
		frameVelocity.y += verticalThrustVector*acceleration*.5
		#Dampening
		if dampeners:
			#Converts universal velocity back to ship-local velocity
			print(rotation)
			print(velocity)
			var shipLocalVelocity = velocity.rotated(Vector3(0,1,0),-rotation.y).rotated(Vector3(1,0,0),-rotation.x).rotated(Vector3(0,0,1),-rotation.z)
			print(shipLocalVelocity)
			if shipLocalVelocity.z != 0 and frameVelocity.z == 0:
				frameVelocity.z -= shipLocalVelocity.z - move_toward(shipLocalVelocity.z,0,acceleration)
			if shipLocalVelocity.x != 0 and frameVelocity.x == 0:
				frameVelocity.x -= shipLocalVelocity.x - move_toward(shipLocalVelocity.x,0,acceleration*.3)
			if shipLocalVelocity.y != 0 and frameVelocity.y == 0:
				frameVelocity.y -= shipLocalVelocity.y - move_toward(shipLocalVelocity.y,0,acceleration*.5) 
		#Rotates frame velocity to universal frame of reference
		#This rotation vector breaks everything:
		#(-0.724, 1.26, -1.29)
		
		frameVelocity = frameVelocity.rotated(Vector3(0,1,0),rotation.y).rotated(Vector3(1,0,0),rotation.x).rotated(Vector3(0,0,1),rotation.z)
		#Applies frame velocity to velocity
		velocity += frameVelocity
		#Apply velocity to position
		position += velocity
	
	#Update UI on Console
	var speed = floor(velocity.length()*100)
	$SubViewport/Label.text = "Speed: "+str(speed)+"\nThrottle: "+str(throttleAmount*100)+"%"
