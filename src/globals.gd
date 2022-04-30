extends Node

var resources = {}
var debug_levels = {}

func _ready():
	resources = load_list( "res://data/resources.json" )
	debug_levels = load_list( "res://data/debug_levels.json" )
	
	
func load_list( file_name ):
	var file = File.new()
	file.open( file_name, file.READ )
	
	var text = file.get_as_text()
	
	var dict = {}
	dict = parse_json( text )
	
	file.close()
	return dict

