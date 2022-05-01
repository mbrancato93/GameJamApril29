extends "res://src/humanoid.gd"

enum Disposition { CASUAL, FRENZY, TRACKING, SATISFIED }
var curr_disposition = Disposition.CASUAL

var path = []
var threshold = 50
var nav = null

var prev_vel = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
#	yield( owner, "ready" )
#	nav = owner.nav
	
	self.add_to_group( "customers" )
	
	set_collision_mask_bit( 3, true )
	set_collision_layer_bit( 3, true )
	
	var view_area = load( "res://objects/view_area.tscn" ).instance()
	view_area.name = "VIEW_AREA"
	self.add_child( view_area )
	
	$VIEW_AREA.get_node( "Area2D/CollisionPolygon2D/Polygon2D" ).visible = Globals.resources[ "Customers" ].show_detection
	
	$VIEW_AREA.get_node("Area2D").connect( "body_entered", self, "body_found" )
	$VIEW_AREA.get_node("Area2D").connect( "body_exited", self, "body_lost" )
	
	var attention_timer = Timer.new()
	attention_timer.name = "Attention"
	self.add_child( attention_timer )
	
	$Attention.connect( "timeout", self, "attention_timeout" )
	pass # Replace with function body.
	
func set_nav( n ):
	nav = n

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if curr_disposition == Disposition.SATISFIED:
		velocity = Vector2( 0, 0 )
		return
	elif path.size() > 0 and curr_disposition == Disposition.TRACKING:
		move_to_target()
	elif curr_disposition == Disposition.CASUAL:
		# dispersion: loop through elements in customer group
		# and substract normalized vector connection them
		var des_direction = Vector2.ZERO
		for customer in get_tree().get_nodes_in_group( "customers" ):
			var direction = global_position.direction_to( customer.global_position )
			if global_position.distance_to( customer.global_position ) <= Globals.resources[ "Customers" ].dispersion_threshold:
				des_direction -= direction.normalized()
		velocity = des_direction * Globals.resources[ id ].speed / 2
		
		# if not being acted upon by others, weight random walk
		if velocity == Vector2( 0, 0 ):
			if prev_vel == Vector2.ZERO:
				velocity = Vector2( Globals.resources[ id ].speed, 0 ) # just do somethin
			else:
				var rnd =  rand_range( 0, 1 )
				velocity = prev_vel
				if( rnd >= Globals.resources[ "Customers" ].random_walk_affinity ):
					velocity = velocity.rotated( PI/2 )
				elif( rnd >= 0.5*(1-Globals.resources[ "Customers" ].random_walk_affinity)+Globals.resources[ "Customers" ].random_walk_affinity ):
					velocity = velocity.rotated( -PI/2 )

	var orientation_angle = atan2( velocity[1], velocity[0] )
	$VIEW_AREA.rotation = orientation_angle
	
	if velocity == Vector2.ZERO:
		# when initializing, look at the orientation state
		if "down" in state_string[ curr_state ]:
			$VIEW_AREA.rotation = PI/2
		elif "up" in state_string[ curr_state ]:
			$VIEW_AREA.rotation = -PI/2
		elif "right" in state_string[ curr_state ]:
			$VIEW_AREA.rotation = 0
		elif "left" in state_string[ curr_state ]:
			$VIEW_AREA.rotation = PI
		
	update_state_machine()
	prev_vel = velocity
	pass
	
func move_to_target():
	if nav == null:
		return
		
	if global_position.distance_to( path[0] ) < threshold:
		path.remove(0)
	else:
		var direction = global_position.direction_to( path[0] )
		velocity = direction * Globals.resources[ id ].speed
		# use this to eliminate need for diagonal animations
		if Globals.resources[ "Customers" ].disable_diagonal:
			# don't allow diagonal motion
			# use the precendence to disable velocity in one direction
			if abs( velocity[0] ) > abs( velocity[1] ):
				velocity[1] = 0
			else:
				velocity[0] = 0
		
#		velocity = move_and_slide( velocity )
		
func get_target_path( target_pos ):
	path = nav.get_simple_path( global_position, target_pos, true )
	
func item_contact( ig ):
	return false
	
func body_found( body ):
	if body.name == "Player" and curr_disposition != Disposition.SATISFIED:
		curr_disposition = Disposition.TRACKING

func body_lost( body ):
	if body.name == "Player" and curr_disposition != Disposition.SATISFIED:
		# ensure disposition is still TRACKING
		curr_disposition = Disposition.TRACKING
		
		# start the timer according to this character's attention span
		$Attention.stop()
		$Attention.wait_time = Globals.resources[ id ].attention
		$Attention.start()
		
func attention_timeout():
#	print_debug( "Attention timeout" )
	curr_disposition = Disposition.CASUAL
	$Attention.stop()
	
func after_physics_process():
	if self.is_on_wall():
		prev_vel = -1 * prev_vel 
	pass
		
	
