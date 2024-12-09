extends Node3D

@onready var dust = $Dust
@onready var bits = $Bits
@onready var small_bits = $SmallBits

@onready var timer = $Timer
@export var dust_time = 2.5

@onready var snowball = get_parent()

func set_explosion_size(scale_factor : float):
	bits.draw_pass_1.radius = bits.draw_pass_1.radius*scale_factor
	bits.draw_pass_1.height = bits.draw_pass_1.height*scale_factor
	#bits.lifetime = bits.lifetime*scale_factor

func explode_and_destroy():
	bits.emitting = true
	small_bits.emitting = true
	dust.emitting = true
	
func _on_bits_finished() -> void:
	timer.start(dust_time)
	
func _on_timer_timeout() -> void:
	if (dust.emitting):
		dust.emitting = false
		timer.start(dust_time) # allow time for dust effect to fade out
	else:
		snowball.queue_free()
