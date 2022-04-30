extends KinematicBody2D
class_name humanoid

var velocity := Vector2( 0, 0 )
var locked := false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not locked:
		velocity = move_and_slide( velocity )
	pass
