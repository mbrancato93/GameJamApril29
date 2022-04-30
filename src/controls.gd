extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_input_by_name( name, method = 0 ):
	if name in Globals.resources[ "Controls" ]:
		if( method == 0 ):
			return Input.get_action_strength( Globals.resources[ "Controls" ][ name ] )
		elif( method == 1 ):
			return Input.is_action_pressed( Globals.resources[ "Controls" ][ name ] )
		elif( method == 2 ):
			return int( Input.is_action_just_released( Globals.resources[ "Controls" ][ name ] ) )
			
func get_input_vector_strength():
	var arr = []
	for key in Globals.resources[ "Controls" ]:
		arr.append( get_input_by_name( Globals.resources[ "Controls" ][ key ], 0 ) )
	return arr
	
func get_input_vector():
	var arr = []
	for key in Globals.resources[ "Controls" ]:
		arr.append( get_input_by_name( Globals.resources[ "Controls" ][ key ], 1 ) )
	return arr

func get_input_vector_released():
	var arr = []
	for key in Globals.resources[ "Controls" ]:
		arr.append( get_input_by_name( Globals.resources[ "Controls" ][ key ], 2 ) )
	return arr
