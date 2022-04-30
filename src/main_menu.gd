extends Node2D

var debug = null


# Called when the node enters the scene tree for the first time.
func _ready():
	assert( Globals.resources != null )
	debug = load( "res://src/debug.gd" ).new()
	debug.setVerb( Globals.debug_levels[ "main_menu" ].verbosity )
	debug.setPeriod( Globals.debug_levels[ "main_menu" ].period )
	
	debug.DEBUG( "Ready done!" )
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Start_pressed():
	debug.DEBUG( "Start button pressed" )
	
	debug.DEBUG( "Locking input!" )
	get_tree().get_root().set_disable_input( true )
	
	debug.DEBUG( "Playing Transition!" )
	var st = get_node( "Container/ScreenTransition/AnimationPlayer" )
	st.play( "Fade" )
	
	debug.DEBUG( "Unlocking input!" )
	get_tree().get_root().set_disable_input( false )
	
	debug.DEBUG( "Moving Scenes" )
	var next_scene = Globals.resources[ "Scenes" ][ "main-menu" ].next
	
	debug.DEBUG( "Transitioning to %s" % Globals.resources[ "Scenes" ][ next_scene ].scene )
	get_tree().change_scene( Globals.resources[ "Scenes" ][ next_scene ].scene )
	pass # Replace with function body.


func _on_Options_pressed():
	debug.DEBUG( "Options button pressed" )
	
	get_node( "Container/Popup/ColorRect/RichTextLabel" ).text = Globals.resources[ "Main_menu" ][ "controls" ]
	get_node( "Container/Popup" ).popup()
	pass # Replace with function body.


func _on_Quit_pressed():
	debug.DEBUG( "Quit button pressed" )
	get_tree().quit()
	pass # Replace with function body.


func _on_Credits_pressed():
	debug.DEBUG( "Credits button pressed" )
	get_node( "Container/Popup/ColorRect/RichTextLabel" ).text = Globals.resources[ "Main_menu" ][ "credits" ]
	get_node( "Container/Popup" ).popup()
	pass # Replace with function body.

func _on_Popup_Close_pressed():
	if get_node( "Container/Popup" ).is_visible(): 
		get_node( "Container/Popup" ).hide()
	pass # Replace with function body.
