extends TextureButton

signal was_pressed

func connect_me(obj):
	connect("was_pressed", obj, "was_pressed", [self])

func _pressed():
	emit_signal("was_pressed")
	var node = get_node("/root/Node2D/Camera2D")
	node.zoomIn()
	
	