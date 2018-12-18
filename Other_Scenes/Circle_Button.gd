extends TextureButton

signal was_pressed

func _pressed():
	emit_signal("was_pressed")
	var node = get_node("/root/Node2D")
	node.circleMap()
	#print("button was_pressed")
	
	