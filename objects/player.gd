extends "res://src/humanoid.gd"

var control = load( "res://src/controls.gd" ).new()

enum State { DOWN, UP, LEFT, RIGHT }

var curr_state = State.DOWN
var anim_state_machine

var inventory = []

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_state_machine = get_node( "Sprite/AnimationTree" ).get( "parameters/playback" )
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# update velocity information based on key presses
	var controls = control.get_input_vector_strength()
	
	# print( controls )
	
	velocity[0] = ( controls[3] - controls[2] ) * Globals.resources[ "Player" ].speed
	velocity[1] = ( controls[1] - controls[0] ) * Globals.resources[ "Player" ].speed
	
	update_state_machine()
		
	pass
	
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

func update_state_machine():
	# right now, just check the velocity and update state accordingly
	# prioritize the up,down direction for now
	if( velocity[1] > 0 and curr_state != State.DOWN ):
		trigger_state_update( State.DOWN )
		curr_state = State.DOWN
	elif( velocity[1] < 0 and curr_state != State.UP ):
		trigger_state_update( State.UP )
		curr_state = State.UP
	elif( velocity[0] > 0 and curr_state != State.RIGHT ):
		trigger_state_update( State.RIGHT )
		curr_state = State.RIGHT
	elif( velocity[0] < 0 and curr_state != State.LEFT ):
		trigger_state_update( State.LEFT )
		curr_state = State.LEFT
		
func trigger_state_update( new_state ):
	if( new_state == State.DOWN ):
		anim_state_machine.travel( "down" )
	if( new_state == State.UP ):
		anim_state_machine.travel( "up" )
	if( new_state == State.LEFT ):
		anim_state_machine.travel( "left" )
	if( new_state == State.RIGHT ):
		anim_state_machine.travel( "right" )
