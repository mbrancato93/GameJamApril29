extends humanoid

var control = load( "res://src/controls.gd" ).new()
var inventory = []
var camera = null
var health = 0

# Called when the node enters the scene tree for the first time.
func _ready():
#	get_node( "Sprite" ).texture = load( Globals.resources[ "Player" ].idle )
#	anim_state_machine = get_node( "Sprite/AnimationTree" ).get( "parameters/playback" )
	id = "Player"
	
	set_collision_mask_bit( 1, false )
	set_collision_layer_bit( 1, true )
	
	debug.setVerb( Globals.debug_levels[ "player" ].verbosity )
	debug.setPeriod( Globals.debug_levels[ "player" ].period )
	
	# this is the main player, so attach a camera
	camera = Camera2D.new()
	camera.set_zoom( Vector2( Globals.resources[ "Player" ].camera_zoom_x, \
						   Globals.resources[ "Player" ].camera_zoom_y ) )
	camera.make_current()
	camera.set_script( load( "res://src/player_cam.gd" ) )
	camera.name = "Camera"
	self.add_child( camera )
	
	
	health = Globals.mission.Player.health
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# update velocity information based on key presses
	var controls = control.get_input_vector_strength()
	
	# print( controls )
	
	velocity[0] = ( controls[3] - controls[2] ) * Globals.resources[ "Player" ].speed
	velocity[1] = ( controls[1] - controls[0] ) * Globals.resources[ "Player" ].speed

	# use this to eliminate need for diagonal animations
	if Globals.resources[ "Player" ].disable_diagonal:
		# don't allow diagonal motion
		# use the precendence to disable velocity in one direction
		if Globals.resources[ "Player" ].direction_precedence == "up/down":
			if velocity[1] != 0:
				velocity[0] = 0
		elif Globals.resources[ "Player" ].direction_precedence == "left/right":
			if velocity[0] != 0:
				velocity[1] = 0 

	update_state_machine()
		
	pass
	
func set_camera_BB( min_x, max_x, min_y, max_y ):
	camera.set_BB( min_x, max_x, min_y, max_y )
	
func handle_collision( collisions ):
	for col in collisions:
		if( col.collider.get_groups().has( "customers" ) ):
			print( "Collided with enemy" )
			
			# move to the next screen
			get_parent().enemy_event( col.collider.name )
			
			break
		
	
func item_contact( name ):
	if len( inventory ) >= Globals.resources[ "Player" ].max_inventory:
		return false
		
	inventory.append( name )
	return true
