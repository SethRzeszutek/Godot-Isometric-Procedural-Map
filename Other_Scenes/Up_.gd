extends TextureButton

signal was_pressed

func _pressed():
	emit_signal("was_pressed")
	var node = get_node("/root/Node2D/Camera2D")
	var delta = get_node("/root/Node2D").get("delta")
	node.Up()
	node._process(delta)

	#print("button was_pressed")
	
	