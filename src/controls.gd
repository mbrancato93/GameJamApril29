extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_input_by_name( name, get_strength = false ):
	if name in Globals.resources[ "Controls" ]:
		if( get_strength ):
			return Input.get_action_strength( Globals.resources[ "Controls" ][ name ] )
		else:
			return Input.is_action_pressed( Globals.resources[ "Controls" ][ name ] )
			
func get_input_vector_strength():
	var arr = []
	for key in Globals.resources[ "Controls" ]:
		arr.append( get_input_by_name( Globals.resources[ "Controls" ][ key ], true ) )
	return arr
	
func get_input_vector():
	var arr = []
	for key in Globals.resources[ "Controls" ]:
		arr.append( get_input_by_name( Globals.resources[ "Controls" ][ key ], false ) )
	return arr

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
