extends AnimatedSprite2D

var relativePosition: Vector3
var radarRange: int

func initIcon():
	#print("Relative Position: " + str(relativePosition))
	if relativePosition.y > 5:
		$Arrow.frame = 0
		$Arrow.visible = true
		$Arrow.position.y = -7
	elif relativePosition.y < -5:
		$Arrow.frame = 1
		$Arrow.visible = true
		$Arrow.position.y = 7
	var scaleFactor = abs(relativePosition.y)*(1.0/radarRange)
	if scaleFactor > 1:
		scaleFactor = 1
	$Arrow.scale = Vector2(scaleFactor,scaleFactor)
	var graphicalPosition = Vector2(relativePosition.x,relativePosition.z) * (50.0/radarRange)
	position = Vector2(graphicalPosition.x + 27,graphicalPosition.y + 27)
	#print("Position: "+str(position))



func _on_area_entered(area):
	var scaleTween = create_tween()
	scaleTween.tween_property(self,"scale",Vector2(.6,.6),.2)
