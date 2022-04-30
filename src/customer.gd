extends "res://src/humanoid.gd"

enum Disposition { CASUAL, FRENZY, TRACKING, SATISFIED }
enum State { DOWN, UP, LEFT, RIGHT }
var curr_state = State.DOWN
var curr_disposition = Disposition.TRACKING
var anim_state_machine

var path = []
var threshold = 50
var nav = null

# Called when the node enters the scene tree for the first time.
func _ready():
	yield( owner, "ready" )
	nav = owner.nav
	
	anim_state_machine = get_node( "Sprite/AnimationTree" ).get( "parameters/playback" )
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if path.size() > 0 and curr_disposition == Disposition.TRACKING:
		move_to_target()
		
	update_state_machine()
	pass
	
func move_to_target():
	if global_position.distance_to( path[0] ) < threshold:
		path.remove(0)
	else:
		var direction = global_position.direction_to( path[0] )
		velocity = direction * Globals.resources[ "Customers" ].speed
		velocity = move_and_slide( velocity )
		
func get_target_path( target_pos ):
	path = nav.get_simple_path( global_position, target_pos, true )
	
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
		
