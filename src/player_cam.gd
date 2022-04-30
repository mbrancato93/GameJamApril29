extends Camera2D

var bb = [ 0, 0, 0, 0 ]

# Called when the node enters the scene tree for the first time.
func _ready():
	print_debug( "Player_cam" )
	pass # Replace with function body.

func set_BB( min_x, max_x, min_y, max_y ):
	bb[0] = min_x
	bb[1] = max_x
	bb[2] = min_y
	bb[3] = max_y
	set_limits()
	
func set_limits():
	self.limit_left = bb[0]
	self.limit_right = bb[1]
	self.limit_top = bb[2]
	self.limit_bottom = bb[3]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
