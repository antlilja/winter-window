extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var scalar: float = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_LEFT):
		global_rotate(Vector3.UP, -delta * scalar)
	if Input.is_key_pressed(KEY_RIGHT):
		global_rotate(Vector3.UP, delta * scalar)
	if Input.is_key_pressed(KEY_UP):
		global_rotate(Vector3.RIGHT, delta * scalar)
	if Input.is_key_pressed(KEY_DOWN):
		global_rotate(Vector3.RIGHT, -delta * scalar)
		
	if Input.is_key_pressed(KEY_PAGEUP):
		global_rotate(Vector3.FORWARD, delta * scalar)
	if Input.is_key_pressed(KEY_PAGEDOWN):
		global_rotate(Vector3.FORWARD, -delta * scalar)
	if Input.is_key_pressed(KEY_SPACE):
		global_position.y += delta * scalar
	if Input.is_key_pressed(KEY_SHIFT):
		position.y -= delta * scalar
	if Input.is_key_pressed(KEY_A):
		position.x += delta * scalar
	if Input.is_key_pressed(KEY_D):
		position.x -= delta * scalar
	
	if Input.is_action_just_pressed("increase_scalar"):
		scalar += 0.1
	
	if Input.is_action_just_pressed("reduce_scalar"):
		scalar -= 0.1
	

	
	scalar = clamp(scalar, 0.0, 2.0)
	
	if Input.is_key_pressed(KEY_O):
		print(rotation)
		print(360 * rotation / (2 * 3.1415))
	pass
