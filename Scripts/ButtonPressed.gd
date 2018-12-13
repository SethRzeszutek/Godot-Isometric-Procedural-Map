extends TextureButton

signal was_pressed

func connect_me(obj, unit_name):
	name = unit_name
	$label.text = unit_name
	connect("was_pressed", obj, "was_pressed", [self])
	print("connect_me")

func _pressed():
	emit_signal("was_pressed")
	print("button was_pressed")
	
	