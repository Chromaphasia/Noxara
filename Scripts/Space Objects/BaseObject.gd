class_name SpaceObject
extends Node3D

#@export var isStellar = true

@export var trueDiameter: float

@onready var originalScale = scale
@onready var localPosition = position
@export var galacticPosition = Vector3()
var scaleFactor:
	set(value):
		scaleFactor = value
		
		
		scale = originalScale*scaleFactor*trueDiameter
		#print(name+" Scale: " + str(scale.x))
		if scale.x <= 0.01:
			visible = false
		else:
			visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	
	add_to_group("Relative Objects")
	add_to_group("Radar Objects")



