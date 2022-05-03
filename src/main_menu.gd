extends Node2D

var debug = null


# Called when the node enters the scene tree for the first time.
func _ready():
	assert( Globals.resources != null )
	debug = load( "res://src/debug.gd" ).new()
	debug.setVerb( Globals.debug_levels[ "main_menu" ].verbosity )
	debug.setPeriod( Globals.debug_levels[ "main_menu" ].period )
	
	debug.DEBUG( "Ready done!" )
	
	# set fonts
	$Container/MarginContainer/VBoxContainer/Start._set_font_path( Globals.resources[ "Scenes" ][ "main-menu" ][ "button_font" ][ "font_path" ] )
	$Container/MarginContainer/VBoxContainer/Controls._set_font_path( Globals.resources[ "Scenes" ][ "main-menu" ][ "button_font" ][ "font_path" ] )
	$Container/MarginContainer/VBoxContainer/Credits._set_font_path( Globals.resources[ "Scenes" ][ "main-menu" ][ "button_font" ][ "font_path" ] )
	$Container/MarginContainer/VBoxContainer/Close._set_font_path( Globals.resources[ "Scenes" ][ "main-menu" ][ "button_font" ][ "font_path" ] )
	
	$Container/Popup/PanelContainer/VBoxContainer/Title.set( "custom_fonts/font", load( Globals.resources[ "Scenes" ][ "main-menu" ][ "title-font" ].font_path ) )
	$Container/Popup/PanelContainer/VBoxContainer/RichTextLabel.set( "custom_fonts/normal_font", load( Globals.resources[ "Scenes" ][ "main-menu" ][ "main_font" ].font_path ) )
	
	$Container/MarginContainer/VBoxContainer/Start.set_text( "START" )
	$Container/MarginContainer/VBoxContainer/Controls.set_text( "CONTROLS" )
	$Container/MarginContainer/VBoxContainer/Credits.set_text( "CREDITS" )
	$Container/MarginContainer/VBoxContainer/Close.set_text( "CLOSE" )
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Popup_Close_pressed():
	if get_node( "Container/Popup" ).is_visible(): 
		get_node( "Container/Popup" ).hide()
	pass # Replace with function body.

func _on_Button_pressed( btn_name ):
	if btn_name == "start":
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
	elif btn_name == "controls":
		debug.DEBUG( "Controls button pressed" )
		get_node( "Container/Popup/PanelContainer/VBoxContainer/Title" ).text = "Controls"
		get_node( "Container/Popup/PanelContainer/VBoxContainer/RichTextLabel" ).text = Globals.resources[ "Main_menu" ][ "controls" ]
		get_node( "Container/Popup" ).popup()
	elif btn_name == "credits":
		debug.DEBUG( "Credits button pressed" )
		get_node( "Container/Popup/PanelContainer/VBoxContainer/Title" ).text = "Credits"
		get_node( "Container/Popup/PanelContainer/VBoxContainer/RichTextLabel" ).text = Globals.resources[ "Main_menu" ][ "credits" ]
		get_node( "Container/Popup" ).popup()
	elif btn_name == "close":
		debug.DEBUG( "Close button pressed" )
		get_tree().quit()
	pass # Replace with function body.
