extends Node2D

var control = load( "res://src/controls.gd" ).new()
var id = "top-down"

onready var nav = $Navigation2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# attempt to load an item
	var item = preload( "res://objects/item.tscn" ).instance()
	item.init( "generic_item" )
	item.position = Vector2( 100, 100 )
	item.scale = Vector2( 0.5, 0.5 )
	self.add_child( item )
	
	item = preload( "res://objects/item.tscn" ).instance()
	item.init( "generic_item" )
	item.position = Vector2( 150, 100 )
	item.scale = Vector2( 0.5, 0.5 )
	self.add_child( item )
	pass # Replace with function body.


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
	var st = get_node( "Container/ScreenTransition/AnimationPlayer" )
	st.play( "Fade" )
#	get_tree().get_root().set_disable_input( false )
	
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
