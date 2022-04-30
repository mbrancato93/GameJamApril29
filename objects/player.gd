extends "res://src/humanoid.gd"

var control = load( "res://src/controls.gd" ).new()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# update velocity information based on key presses
	var controls = control.get_input_vector_strength()
	
	velocity[0] = controls[3] - controls[4]
	velocity[1] = controls[2] - controls[1]
		
	pass
