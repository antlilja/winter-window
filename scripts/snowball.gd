extends XRToolsPickable

@onready var mesh = $MeshInstance3D
@onready var collisionShape = $CollisionShape3D
@onready var polygonShape = $CollisionPolygon3D

@export var is_grounded = false

# roll variables
@export var scale_factor = 1.01
@export var max_size = 1
@export var speed_threshold = 0.5 # avoid snowball rapidly growing because of a slight rolling

# stack variables
@export var attatched_snowballs = 0


func _physics_process(_delta : float):
	var current_radius = mesh.mesh.radius * mesh.scale.x
	# grow snowball if moving on ground
	if is_grounded and linear_velocity.length() > speed_threshold and current_radius < max_size:
		mesh.scale = mesh.scale*scale_factor
		collisionShape.scale = collisionShape.scale*scale_factor
		polygonShape.scale = polygonShape.scale*scale_factor
		
func init_large():
	collisionShape.scale = collisionShape.scale*10
	mesh.scale = mesh.scale*10
	polygonShape.scale = polygonShape.scale*10
	
func lock_position():
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	#self.freeze = true
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_X, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Y, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, true)
	
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Z, true)
	
func unlock_position():
	#self.freeze = false
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_X, false)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Y, false)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, false)
	
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, false)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, false)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Z, false)

func set_grounded(grounded : bool):
	is_grounded = grounded
	if (grounded):
		
		add_to_group("grounded")
	else:
		remove_from_group("grounded")
	
func _on_body_entered(body):
	if body.is_in_group("ground"):
		set_grounded(true)
		
	if body.is_in_group("snowball"):
		# don't attatch two grounded snowballs
		if is_grounded and body.is_in_group("grounded"):
			return
			
		attatched_snowballs += 1
		lock_position()
		
	if body.is_in_group("controller") and not is_grounded: # could be more restrictive but would risk deadlock
		print("Collision with controller")
		unlock_position()

func _on_body_exited(body) -> void:
	if body.is_in_group("ground"):
		set_grounded(false)
		
	if body.is_in_group("snowball"):
		attatched_snowballs -= 1
		if attatched_snowballs < 1:
			unlock_position()

func _on_grabbed(pickable: Variant, by: Variant) -> void:
	unlock_position()
