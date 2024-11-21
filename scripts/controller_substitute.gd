extends RigidBody3D

var snowball_scene = preload("res://scenes/snowball.tscn")
var current_snowball: RigidBody3D = null

# testing variables
var push_force = 0.1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#  move hand subsitute
	if Input.is_action_pressed("move_right"):
		apply_impulse(Vector3(push_force,0,0))
	if Input.is_action_pressed("move_left"):
		apply_impulse(Vector3(-push_force,0,0))
	if Input.is_action_pressed("move_back"):
		apply_impulse(Vector3(0,0,push_force))
	if Input.is_action_pressed("move_forward"):
		apply_impulse(Vector3(0,0,-push_force))
	if Input.is_action_pressed("move_up"):
		apply_impulse(Vector3(0,push_force/2,0))
	if Input.is_action_pressed("move_down"):
		apply_impulse(Vector3(0,-push_force/2,0))
	
	if Input.is_action_just_pressed("reset_velocity"):
		linear_velocity = Vector3.ZERO
	if Input.is_action_just_pressed("lock_y_axis"):
		set_axis_lock(2, not axis_lock_linear_y)
	
	# create snowball
	if Input.is_action_just_pressed("create_snowball"):
		create_snowball()
		
	if Input.is_action_just_released("create_snowball"):
		if (current_snowball != null):
			current_snowball.reparent($".")

func create_snowball():
	var snowball: RigidBody3D = snowball_scene.instantiate()
	current_snowball = snowball
	add_child(snowball)
