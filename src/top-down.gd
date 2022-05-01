extends Node2D

var control = load( "res://src/controls.gd" ).new()
var debug = load( "res://src/debug.gd" ).new()
var id = "top-down"

onready var nav = $Navigation2D

# Called when the node enters the scene tree for the first time.
func _ready():
	debug.setVerb( Globals.debug_levels[ "top-down" ].verbosity )
	debug.setPeriod( Globals.debug_levels[ "top-down" ].period )
	
	if Globals.mission.Prime:
		debug.DEBUG( "Priming mission: %s" % Globals.mission.Name )
		prime()
		Globals.mission.Prime = false
	pass # Replace with function body.

func prime():
	var player = create_character( "Player", Vector2( 100, 100 ) )
#	player.add_to_group( "player" )
	
	var map_limits = $Navigation2D/TileMap.get_used_rect()
	var map_cellsize = $Navigation2D/TileMap.cell_size
	self.add_child( player )
	
	var min_x = map_limits.position.x * map_cellsize.x
	var max_x = map_limits.end.x * map_cellsize.x
	var min_y = map_limits.position.y * map_cellsize.y
	var max_y = map_limits.end.y * map_cellsize.y
	$Player.set_camera_BB( min_x, \
				  	 	   max_x, \
				   		   min_y, \
				   		   max_y )
	
	var placement = Vector2( floor(rand_range(min_x,max_x)),floor(rand_range(min_y,max_y)) )
	# as a test, load all items
	for name in Globals.mission[ "Items" ]:
		for _num in range( Globals.mission[ "Items" ][ name ].number ):
			var item = create_item( name, placement )
			self.add_child( item )
			placement = Vector2( floor(rand_range(min_x,max_x)),floor(rand_range(min_y,max_y)) )
	
	# generate enemies in random positions given mission parameters
	var num_enemies = Globals.mission.Customers.number
	debug.DEBUG( "Generating %d enemies" % num_enemies )
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	placement = Vector2( floor(rand_range(min_x,max_x)),floor(rand_range(min_y,max_y)) )
	for i in num_enemies:
		var customer_name = Globals.resources[ "Customers" ].names[ rng.randi_range( 0, len(Globals.resources[ "Customers" ].names)-1 ) ]
		debug.DEBUG( "Creating customer %s" % customer_name )
		
		var customer = create_character( customer_name, placement )
		customer.set_nav( $Navigation2D )
		self.add_child( customer )
		placement = Vector2( floor(rand_range(min_x,max_x)),floor(rand_range(min_y,max_y)) )
		
	write_time( Globals.mission.Time )
	$CanvasLayer/Container/ProgressBar.value = $Player.health
	$Timer2.wait_time = Globals.mission.TimeStep[1]
	$Timer2.start()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if control.get_input_by_name( "inventory" ) and not get_node( "CanvasLayer/Inventory" ).is_visible():
		get_tree().paused = true
		get_node( "CanvasLayer/Inventory" ).popup( )
		# get_tree().paused = false
	pass
	
func enemy_event( enemy_id ):
	go_to_battle( enemy_id )
	
func go_to_battle( customer_id ):
	get_tree().paused = true
	save_parameters()
	var st = get_node( "Container/ScreenTransition/AnimationPlayer" )
	st.play( "Fade" )
#	get_tree().get_root().set_disable_input( false )
	
func save_parameters():
	# player stats
	Globals.mission.Player.health = $Player.health
	Globals.mission.Player.position = $Player.global_position
	Globals.mission.Player.state = $Player.curr_state
	
	# Time is logged throughout
	
	# Customers
	var counter = 0
	for customer in get_tree().get_nodes_in_group( "customers" ):
		var dict = {
			"name": customer.id,
			"position": customer.global_position,
			"state": customer.curr_state
		}
		Globals.mission.Customers[ "%d" % counter ] = dict
		counter += 1
		
	# Items
	
	for item in get_tree().get_nodes_in_group( "items" ):
#		Globals.mission.Items[ istem.type ].append( "item%d" % counter:.position = item.global_position
		var dict = { "position": item.global_position }
		Globals.mission.Items[ item.type ] = { "item%d" % counter: dict }
		counter += 1
	
	# save for debugging purposes
	var save_file = File.new()
	save_file.open( "res://data/debug.json", File.WRITE )
	save_file.store_line( to_json( Globals.mission ) )
	save_file.close()
	pass
	
func next_scene():
	get_tree().paused = false
	var tmp = Globals.resources[ "Scenes" ][ id ].next
	get_tree().change_scene( Globals.resources[ "Scenes" ][ tmp ].scene )

func _on_Inventory_popup_hide():
	# remove elements from GridContainer
	for N in get_node( "CanvasLayer/Inventory/ColorRect/CenterContainer/GridContainer" ).get_children():
		N.queue_free()
	
	get_tree().paused = false
	pass # Replace with function body.


func _on_Inventory_about_to_show():
	# grab the items in the inventory and display in the rich text window
	var ind = 0
	for i in range( Globals.resources[ "Player" ].max_inventory ):
		var inventory_btn = load( Globals.resources[ "Inventory" ].button_scn ).instance()
		
		if i < len( $Player.inventory ) and len( $Player.inventory ) != 0:
			inventory_btn._set_label( $Player.inventory[i] )
			# load the corresponding image
			inventory_btn._set_image( $Player.inventory[i] )
		else:
			inventory_btn._set_label( "" )
			inventory_btn._set_button_availability( false )
		get_node( "CanvasLayer/Inventory/ColorRect/CenterContainer/GridContainer" ).add_child( inventory_btn )
		
	pass # Replace with function body.


func _on_Timer_timeout():
	get_tree().call_group( "customers", "get_target_path", $Player.global_position )
	pass # Replace with function body.

func create_item( type, pos: Vector2 ):
	var item = load( "res://objects/item.tscn" ).instance()
	item.init( type )
	item.position = pos
	item.scale = Vector2( Globals.resources[ "Items" ][ type ].x_scale, \
							Globals.resources[ "Items" ][ type ].y_scale )
	return item

func create_character( type, pos: Vector2 ):
	var character = load( "res://objects/humanoid.tscn" ).instance()
	character.global_position = pos
	if type == "Player":
		character.script = load( "res://src/player.gd" )
	else:
		character.script = load( "res://src/customer.gd" )
	character.set_name( type )
	character.name = type
	return character

func update_time( tm ):
	Globals.mission.Time += tm

func write_time( t ):
	var hr = floor( t/100 )
	var m = 60*( t - hr*100 ) / 100
	$CanvasLayer/Container/TimeClock.text = "%2.0f:%02.0f" % [ hr, m ]
	pass

func _on_Timer2_timeout():
	# time to update the time clock
	update_time( Globals.mission.TimeStep[0] )
	write_time( Globals.mission.Time )
	if Globals.mission.Time == Globals.mission.EndTime:
		get_tree().paused = true
		$CanvasLayer/Inventory.popup()
		$Timer2.stop()
	pass # Replace with function body.
