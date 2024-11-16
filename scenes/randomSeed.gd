extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material_override.set("shader_parameter/seed", randi());
	
	
	
		
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
