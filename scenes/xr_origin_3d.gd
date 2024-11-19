extends XROrigin3D

var snowball_scene = preload("res://scenes/snowball.tscn")
var current_snowball: RigidBody3D = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var interface = XRServer.find_interface("OpenXR")
	get_viewport().use_xr = true;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_snowball_on_hand(hand_node: XRNode3D) -> void:
	var snowball: RigidBody3D = snowball_scene.instantiate()
	current_snowball = snowball
	hand_node.add_child(snowball)
	pass
	
func _on_right_hand_button_pressed(name: String) -> void:
	match name:
			"trigger_click": create_snowball_on_hand($RightHand)
	pass # Replace with function body.


func _on_right_hand_input_float_changed(name: String, value: float) -> void:
	print(name + " value: " + str(value))
	pass # Replace with function body.


func _on_right_hand_button_released(name: String) -> void:
	print(name)
	match name:
			"trigger_click": 
				if (current_snowball != null):
					current_snowball.reparent($".")
	pass # Replace with function body.
