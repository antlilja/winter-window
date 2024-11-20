extends RigidBody3D

@onready var collision = $CollisionShape3D
@onready var mesh = $MeshInstance3D

# push variables
@export var grounded = true
@export var scale_factor = 1.001

# testing variables
var push_force = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# test inputs to move snowball
	if Input.is_action_pressed("move_right"):
		apply_impulse(Vector3(push_force,0,0))
	if Input.is_action_pressed("move_left"):
		apply_impulse(Vector3(-push_force,0,0))
	if Input.is_action_pressed("move_back"):
		apply_impulse(Vector3(0,0,push_force))
	if Input.is_action_pressed("move_forward"):
		apply_impulse(Vector3(0,0,-push_force))
		
	# grow snowball if moving on ground
	if grounded and linear_velocity.length() > 0.5:
		collision.scale = collision.scale*scale_factor
		mesh.scale = mesh.scale*scale_factor

func _on_body_entered(body):
	print("collision")

func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	print("collision")
