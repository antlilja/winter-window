extends Node3D
var snowball_scene = preload("res://scenes/snowball.tscn")

@export var init_large = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func create_snowball(position : Vector3):
	var snowball: RigidBody3D = snowball_scene.instantiate()
	snowball.linear_velocity = Vector3.ZERO
	snowball.position = position + Vector3(0,-1,0)
	
	add_child(snowball)
	if init_large:
		snowball.init_large()
