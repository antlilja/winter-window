extends XRToolsPickable

@onready var mesh = $MeshInstance3D
@onready var collisionShape = $CollisionShape3D
@onready var triggerArea = $Area3D

@export var is_grounded = false

# roll variables
@export var scale_factor_small = 1.01
@export var scale_factor_large = 1.001
@export var radius_small = 0.05
@export var radius_large = 0.5

@export var max_size = 0.5
@export var speed_threshold = 0.5 # avoid snowball rapidly growing because of a slight rolling

# stack variables
@export var attatched_snowballs = 0

# pickup
var max_disable_collision_time = 0.1
var disable_collision_time = 0

# destruction variables
var collision_velocity = Vector3.ZERO
var explosion_speed_thresh = 4

@onready var snow_material: Material = mesh.get_active_material(0);


func _physics_process(delta : float):
	var current_radius = mesh.mesh.radius * mesh.scale.x
	# grow snowball if moving on ground
	if is_grounded and linear_velocity.length() > speed_threshold and current_radius < max_size:
		# scale scalefactor
		var f = (current_radius - radius_small) / (radius_large - radius_small)
		var v = (scale_factor_large - scale_factor_small)*f + scale_factor_small
		var scale_factor = clamp(v, scale_factor_large, scale_factor_small)
			
		mesh.scale = mesh.scale*scale_factor
		collisionShape.scale = collisionShape.scale*scale_factor
		triggerArea.scale = triggerArea.scale*scale_factor
		
		snow_material.set_shader_parameter("object_scale", mesh.scale.x)
				
	if is_grounded:
		linear_velocity += -linear_velocity*0.1
		angular_velocity += -angular_velocity*0.5
		
	if global_position.y < 0.5: # hard coded ground level
		pass#global_position.y = 0 + 0.5 + current_radius # ground position.y, ground size.y
		
	if disable_collision_time > 0:
		disable_collision_time -= delta
		if disable_collision_time < 0:
			set_collision_mask_value(18, true)
		
func init_large():
	collisionShape.scale = collisionShape.scale*10
	mesh.scale = mesh.scale*10
	triggerArea.scale = triggerArea.scale*10
	
func lock_position():
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	set_collision_mask_value(18, false)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_X, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Y, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, true)
	
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Z, true)
	
func unlock_position():
	set_collision_mask_value(18, true)
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
	if collision_velocity.length() > explosion_speed_thresh or body.is_in_group("camera"):
		print("Explosion!")
		# TODO trigger particle effect
		# TODO remove self
		return
	
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
	set_collision_mask_value(18, true)
	unlock_position()

func _on_dropped(pickable: Variant) -> void:	
	disable_collision_time = max_disable_collision_time
	set_collision_mask_value(18, false)

func _on_area_3d_area_entered(area: Area3D) -> void:
	collision_velocity = linear_velocity
