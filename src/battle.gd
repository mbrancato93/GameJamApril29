extends Node2D

var debug = load( "res://src/debug.gd" ).new()

var control = load( "res://src/controls.gd" ).new()

var menu_selection = 0

var id = "battle"

# Called when the node enters the scene tree for the first time.
func _ready():
	debug.setVerb( Globals.debug_levels[ "main_menu" ].verbosity )
	debug.setPeriod( Globals.debug_levels[ "main_menu" ].period )
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var controls = control.get_input_vector_released()
	menu_selection = min( max( menu_selection + controls[1] - controls[0], 0 ), len( Globals.resources[ "Battle" ].options )-1 )
	
	var opts_str = "" 
	for i in range( len( Globals.resources[ "Battle" ].options ) ):
		if i == menu_selection:
			opts_str += ">"
		else:
			opts_str += " "
			
		opts_str += Globals.resources[ "Battle" ].options[i] + "\n"
	
	$Container/CanvasLayer/ColorRect2/RichTextLabel.text = opts_str
	
	if controls[4]:
		# execute the action at menu_selection ind
		print( "Selected ", Globals.resources[ "Battle" ].options[ menu_selection ] )
		if Globals.resources[ "Battle" ].options[ menu_selection ] == "Run":
			next_scene()
	pass

func next_scene():
	var tmp = Globals.resources[ "Scenes" ][ id ].next
	get_tree().change_scene( Globals.resources[ "Scenes" ][ tmp ].scene )
