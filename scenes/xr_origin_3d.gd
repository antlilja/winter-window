extends XROrigin3D

var snowball_scene = preload("res://scenes/snowball_pickable.tscn") #preload("res://scenes/snowball.tscn")
var current_snowball: RigidBody3D = null
@onready var right_hand: XRController3D = $RightHand

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#var interface = XRServer.find_interface("OpenXR")
	get_viewport().use_xr = true;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
