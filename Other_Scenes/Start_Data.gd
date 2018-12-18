extends TextureButton

signal was_pressed

func _pressed():
	emit_signal("was_pressed")
	var node = get_node("/root/Node2D/UI/Base/SizeGroup/Size")
	node.set_text("80")
	node = get_node("/root/Node2D/UI/Base/OctaveGroup/Octave")
	node.set_text("6")
	node = get_node("/root/Node2D/UI/Base/PeriodGroup/Period")
	node.set_text("30")
	node = get_node("/root/Node2D/UI/Base/PersistGroup/Persistence")
	node.set_text("0.4")
	
	