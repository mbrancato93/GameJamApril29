extends KinematicBody2D
class_name humanoid

var velocity := Vector2( 0, 0 )
var locked := false

var debug = load( "res://src/debug.gd" ).new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not locked:
		velocity = move_and_slide( velocity )
		var collisions = []
		for i in get_slide_count():
			var collision = get_slide_collision( i )
			collisions.append( collision )
		handle_collision( collisions )
	pass

func handle_collision( collision ):
	# overloaded by inhereters
	pass
