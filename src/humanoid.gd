extends KinematicBody2D
class_name humanoid

var velocity := Vector2( 0, 0 )
var locked := false

var debug = load( "res://src/debug.gd" ).new()

enum State { FACING_DOWN, FACING_UP, FACING_LEFT, FACING_RIGHT, \
			 WALKING_DOWN, WALKING_UP, WALKING_LEFT, WALKING_RIGHT }
			
var state_string = [ "facing_down", "facing_up", "facing_left", "facing_right", \
					 "walking_down", "walking_up", "walking_left", "walking_right" ]
			
var curr_state = State.FACING_DOWN
var id = "humanoid"
var curr_texture_path = ""

var anim_state_machine
# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite/AnimationPlayer.play( state_string[ curr_state ] )
#	anim_state_machine = get_node( "Humanoid/Sprite/AnimationTree" ).get( "parameters/playback" )
	pass # Replace with function body.

func set_name( n ):
	id = n
	anim_event( state_string[ curr_state ] )
	$Sprite/AnimationPlayer.play( state_string[ curr_state ] )

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
	
func update_state_machine():
	# right now, just check the velocity and update state accordingly
	# prioritize the up,down direction for now
	if( velocity[1] > 0 and curr_state != State.WALKING_DOWN ):
		trigger_state_update( State.WALKING_DOWN )
		curr_state = State.WALKING_DOWN
	elif( velocity[1] < 0 and curr_state != State.WALKING_UP ):
		trigger_state_update( State.WALKING_UP )
		curr_state = State.WALKING_UP
	elif( velocity[0] > 0 and curr_state != State.WALKING_RIGHT ):
		trigger_state_update( State.WALKING_RIGHT )
		curr_state = State.WALKING_RIGHT
	elif( velocity[0] < 0 and curr_state != State.WALKING_LEFT ):
		trigger_state_update( State.WALKING_LEFT )
		curr_state = State.WALKING_LEFT
	elif( velocity[0] == 0 and velocity[1] == 0 ):
		if curr_state == State.WALKING_DOWN:
			trigger_state_update( State.FACING_DOWN )
			curr_state = State.FACING_DOWN
		elif curr_state == State.WALKING_UP:
			trigger_state_update( State.FACING_UP )
			curr_state = State.FACING_UP
		elif curr_state == State.WALKING_LEFT:
			trigger_state_update( State.FACING_LEFT )
			curr_state = State.FACING_LEFT
		elif curr_state == State.WALKING_RIGHT:
			trigger_state_update( State.FACING_RIGHT )
			curr_state = State.FACING_RIGHT
		
func trigger_state_update( new_state ):
	if( new_state == State.WALKING_DOWN ):
#		anim_state_machine.travel( "walking_down" )
		$Sprite/AnimationPlayer.play( "walking_down" )
	elif( new_state == State.WALKING_UP ):
#		anim_state_machine.travel( "walking_up" )
		$Sprite/AnimationPlayer.play( "walking_up" )
	elif( new_state == State.WALKING_LEFT ):
#		anim_state_machine.travel( "walking_left" )
		$Sprite/AnimationPlayer.play( "walking_left" )
	elif( new_state == State.WALKING_RIGHT ):
#		anim_state_machine.travel( "walking_right" )
		$Sprite/AnimationPlayer.play( "walking_right" )
	elif( new_state == State.FACING_DOWN ):
#		anim_state_machine.travel( "facing_down" )
		$Sprite/AnimationPlayer.play( "facing_down" )
	elif( new_state == State.FACING_LEFT ):
#		anim_state_machine.travel( "facing_left" )
		$Sprite/AnimationPlayer.play( "facing_left" )
	elif( new_state == State.FACING_RIGHT ):
#		anim_state_machine.travel( "facing_right" )
		$Sprite/AnimationPlayer.play( "facing_right" )
	elif( new_state == State.FACING_UP ):
#		anim_state_machine.travel( "facing_up" )
		$Sprite/AnimationPlayer.play( "facing_up" )

	
func anim_event( event_name ):
	var tex = ""
	if "facing" in event_name:
		tex = Globals.resources[ id ].idle
	elif "walking" in event_name:
		tex = Globals.resources[ id ].walking
		
	if curr_texture_path != tex:
		$Sprite.texture = load( tex )
		curr_texture_path = tex
