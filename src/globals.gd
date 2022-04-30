extends Node

var resources = {}
var debug_levels = {}
var mission = {}

func _ready():
	resources = load_list( "res://data/resources.json" )
	assert( resources )
	debug_levels = load_list( "res://data/debug_levels.json" )
	assert( debug_levels )
	mission = load_list( "res://data/mission.json" )
	assert( mission )
	
	
func load_list( file_name ):
	var file = File.new()
	file.open( file_name, file.READ )
	
	var text = file.get_as_text()
	
	var dict = {}
	dict = parse_json( text )
	
	file.close()
	return dict

