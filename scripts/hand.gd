extends XRController3D

var previous_position: Vector3 = Vector3.ZERO
var velocity_buffer: Array[Vector3] = []
const VEL_BUFFER_SIZE = 3
var vel_buffer_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	velocity_buffer.resize(VEL_BUFFER_SIZE)
	velocity_buffer.fill(Vector3.ZERO)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Calculate current velocity and add to rolling buffer
	var current_position = self.global_position
	var instant_velocity = (current_position - previous_position)/delta
	velocity_buffer[vel_buffer_index] = instant_velocity
	vel_buffer_index += 1
	vel_buffer_index %= len(velocity_buffer)
	previous_position = current_position

func get_velocity() -> Vector3:
	# Calculate rolling average velocity
	var sum = Vector3.ZERO
	for v in velocity_buffer:
		sum += v
	return sum/len(velocity_buffer)
