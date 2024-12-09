extends XRToolsPickable

@onready var mesh = $MeshInstance3D
@onready var collision_shape = $CollisionShape3D
@onready var velocity_trigger = $VelocityTrigger
@onready var explosion_effect = $Explosion

@export var is_grounded = false
@export var is_grabbed = false
var current_radius

# roll variables
@export var scale_factor_small = 1.01
@export var scale_factor_large = 1.001
@export var radius_small = 0.05
@export var radius_large = 0.5

@export var max_size = 0.5
@export var speed_threshold = 0.5 # avoid snowball rapidly growing because of a slight rolling

# pickup
var max_disable_collision_time = 0.1
var disable_collision_time = 0

# destruction variables
var collision_velocity = Vector3.ZERO
var explosion_speed_thresh = 4
# stacking
@export var balance_thresh = 0.9 # [0,1]
@export var balance_thresh_lower = 0.1 # for smaller snowballs, or with multiple snowballs supporting it

@onready var snow_material: Material = mesh.get_active_material(0);

func _physics_process(delta : float):
	current_radius = mesh.mesh.radius * mesh.scale.x
	# grow snowball if moving on ground
	if is_grounded and not is_grabbed and linear_velocity.length() > speed_threshold and current_radius < max_size:
		# scale scalefactor
		var f = (current_radius - radius_small) / (radius_large - radius_small)
		var v = (scale_factor_large - scale_factor_small)*f + scale_factor_small
		var scale_factor = clamp(v, scale_factor_large, scale_factor_small)
			
		mesh.scale = mesh.scale*scale_factor
		collision_shape.scale = collision_shape.scale*scale_factor
		velocity_trigger.scale = velocity_trigger.scale*scale_factor
		
		snow_material.set_shader_parameter("object_scale", mesh.scale.x)
		
		if current_radius > 0.25:
			explosion_effect.set_explosion_size(10)
				
	if is_grounded:
		linear_velocity += -linear_velocity*0.1
		angular_velocity += -angular_velocity*0.5
		
	if global_position.y < 0.5: # hard coded ground level
		pass #global_position.y = 0 + 0.5 + current_radius # ground position.y, ground size.y
		
	if disable_collision_time > 0:
		disable_collision_time -= delta
		if disable_collision_time < 0:
			set_collision_mask_value(18, true)
		
func init_large():
	collision_shape.scale = collision_shape.scale*10
	mesh.scale = mesh.scale*10
	velocity_trigger.scale = velocity_trigger.scale*10
	
	explosion_effect.set_explosion_size(10)
	
func lock_position():
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	set_collision_mask_value(18, false)
	enabled = false # enables pickable property

	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_X, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Y, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_LINEAR_Z, true)
	
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_X, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Y, true)
	set_axis_lock(PhysicsServer3D.BodyAxis.BODY_AXIS_ANGULAR_Z, true)

func set_grounded(grounded : bool):
	is_grounded = grounded
	if (grounded):
		add_to_group("grounded")
	else:
		remove_from_group("grounded")
		
func destroy_self():
	# stop center of particle effects from moving
	lock_position()
	
	# trigger particle effect
	explosion_effect.explode_and_destroy()
	
	# remove snowball
	remove_child(mesh)
	remove_child(collision_shape)	
	
func _on_body_entered(body):
	if collision_velocity.length() > explosion_speed_thresh or body.is_in_group("camera"):
		destroy_self()
		return
	
	if body.is_in_group("ground"):
		set_grounded(true)		
		
	if body.is_in_group("snowball"):
		# don't attatch two grounded snowballs
		if is_grounded and body.is_in_group("grounded"):
			return
		
		# lower balance thresh if small snowball
		var current_balance_thresh = balance_thresh
		if current_radius < 0.1:
			current_balance_thresh = balance_thresh_lower
		
		# check balance against single snowball
		if (position - body.position).normalized().y > current_balance_thresh:
			lock_position()
			body.lock_position()
			return
		
		# check balance against all colliding snowballs with lower requirement on balance
		var support_count = 0
		var collisions = get_colliding_bodies()
		for c in collisions:
			if c.is_in_group("snowball"):
				if (position - c.position).normalized().y > balance_thresh_lower:
					support_count += 1
		
		if support_count > 1:
			lock_position()
			for c in collisions:
				if c.is_in_group("snowball"):
					c.lock_position()

func _on_body_exited(body) -> void:
	if body.is_in_group("ground"):
		set_grounded(false)

func _on_grabbed(pickable: Variant, by: Variant) -> void:
	set_collision_mask_value(18, true)
	is_grabbed = true

func _on_dropped(pickable: Variant) -> void:	
	disable_collision_time = max_disable_collision_time
	set_collision_mask_value(18, false)

func _on_area_3d_area_entered(area: Area3D) -> void:
	collision_velocity = linear_velocity
	is_grabbed = false
