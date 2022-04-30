extends "res://src/humanoid.gd"

enum Disposition { CASUAL, FRENZY, TRACKING, SATISFIED }
var curr_disposition = Disposition.SATISFIED

var path = []
var threshold = 50
var nav = null

# Called when the node enters the scene tree for the first time.
func _ready():
#	yield( owner, "ready" )
#	nav = owner.nav
	
	self.add_to_group( "customers" )
	
	set_collision_mask_bit( 3, true )
	set_collision_layer_bit( 3, true )
	pass # Replace with function body.
	
func set_nav( n ):
	nav = n

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if path.size() > 0 and curr_disposition == Disposition.TRACKING:
		move_to_target()
	elif curr_disposition == Disposition.CASUAL:
		# dispersion: loop through elements in customer group
		# and substract normalized vector connection them
		var des_direction = Vector2.ZERO
		for customer in get_tree().get_nodes_in_group( "customers" ):
			var direction = global_position.direction_to( customer.global_position )
			if global_position.distance_to( customer.global_position ) <= Globals.resources[ "Customers" ].dispersion_threshold:
				des_direction -= direction.normalized()
		velocity = des_direction * Globals.resources[ id ].speed / 10
	elif curr_disposition == Disposition.SATISFIED:
		# do nothing
		pass
		
	update_state_machine()
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
	
