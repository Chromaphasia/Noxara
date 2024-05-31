extends CharacterBody3D


@export var manueverability = 1

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	const mouseVelocityAdjustment = 1
	const maximumMouseVelocity = 10
	var mouseVelocity = Input.get_last_mouse_velocity()*mouseVelocityAdjustment*Options.flyingMouseSensitivity
	if mouseVelocity.length() > maximumMouseVelocity:
		mouseVelocity = mouseVelocity.limit_length(maximumMouseVelocity)
	#Pitch and Roll for Mouse
	if mouseVelocity.x >= 0:
		rotation.x = move_toward(rotation.x, rotation.x+(2*PI),mouseVelocity.x*manueverability)
	else:
		rotation.x = move_toward(rotation.x, rotation.x-(2*PI),-mouseVelocity.x*manueverability)
	if mouseVelocity.y >= 0:
		rotation.z = move_toward(rotation.z, rotation.z+(2*PI),mouseVelocity.y*manueverability)
	else:
		rotation.z = move_toward(rotation.z, rotation.z-(2*PI),-mouseVelocity.y*manueverability)
	#Pitch and Roll for controller
	var controllerVector = Input.get_vector("PitchDown","PitchUp","RollDown","RollUp")
	rotation.x += controllerVector.x
	rotation.z += controllerVector.y
	#Precise Pitch and Yaw for Keyboard:
	
	move_and_slide()
