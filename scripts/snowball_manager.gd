extends Node3D
var snowball_scene = preload("res://scenes/snowball.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_snowball(position : Vector3):
	var snowball: RigidBody3D = snowball_scene.instantiate()
	snowball.linear_velocity = Vector3.ZERO
	snowball.position = position
	
	add_child(snowball)
	snowball.init_large()
