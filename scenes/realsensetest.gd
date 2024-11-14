extends Node3D


@onready var texture_rect = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	RealSense.open()
	
	var image = Image.create(1920, 1080, false, Image.Format.FORMAT_RGB8)
	image.fill(Color.RED)
	texture_rect.texture.set_image(image)

func _notification(what: int) -> void:
	if (what == NOTIFICATION_PREDELETE):
		RealSense.close()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	RealSense.poll_frame()
	var data = RealSense.get_colour_image()
	var image = Image.create_from_data(1920, 1080, false, Image.Format.FORMAT_RGB8, data)
	texture_rect.texture.set_image(image)
