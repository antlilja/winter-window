extends XROrigin3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var interface = XRServer.find_interface("OpenXR")
	get_viewport().use_xr = true;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_right_hand_button_pressed(name: String) -> void:
	print(name)
	pass # Replace with function body.


func _on_right_hand_input_float_changed(name: String, value: float) -> void:
	print(name + " value: " + str(value))
	pass # Replace with function body.
