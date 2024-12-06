extends RigidBody3D

var current_snowball: RigidBody3D = null

# testing variables
var push_force = 0.1

func _process(delta: float) -> void:		
	# create snowball
	if Input.is_action_just_pressed("create_snowball"):
		create_snowball()
		
	if Input.is_action_just_released("create_snowball"):
		if (current_snowball != null):
			current_snowball.reparent($".")
			
	# control velocity
	if Input.is_action_just_pressed("reset_velocity"):
		if linear_velocity != Vector3.ZERO:
			linear_velocity = Vector3.ZERO
		else:
			position = Vector3.ZERO
		
	if Input.is_action_just_pressed("lock_y_axis"):
		set_axis_lock( PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Y, not axis_lock_linear_y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta: float) -> void:
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


func create_snowball():
	%SnowballManager.create_snowball(position)
